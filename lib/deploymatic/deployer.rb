require 'debug'
require 'erb'
require 'ostruct'
require 'sshkit'
require 'sshkit/dsl'
require 'yaml'

module Deploymatic
  class DeploymaticError < StandardError; end

  class Deployer
    include SSHKit::DSL

    SSHKit::Backend::Netssh.configure do |ssh|
      ssh.connection_timeout = 30
      ssh.ssh_options = {
        auth_methods: %w[publickey],
        keepalive: true
      }
    end

    def initialize(config_file_path)
      @conf = Conf.new(**YAML.load_file(config_file_path))
      @conf.check_required_fields!

      result, ok = run(:echo, '$HOME')
      raise DeploymaticError.new("Unable to retrieve the user's home directory on the remote host: #{result}") unless ok

      @home_dir = result.strip
      @conf.install_dir.gsub!('$HOME', @home_dir)
    end

    def install
      # puts systemd_unit_file_to_string
      _, ok = run(:systemd, '--version')
      raise DeploymaticError.new('systemd is not installed on the remote host') unless ok

      _, ok = run(:git, '--version')
      raise DeploymaticError.new('git is not installed on the remote host') unless ok

      result, ok = run(:ls, '/var/lib/systemd/linger/')
      raise DeploymaticError.new("User #{@conf.ssh_user} is not in the lingering list") if !ok || !result.include?(@conf.ssh_user)

      result, ok = run(:mkdir, '-p', @conf.install_dir)
      raise DeploymaticError.new("Cannot create directory '#{@conf.install_dir}': #{result}") unless ok

      result, ok = run(:git, 'clone', @conf.repo, '.', within: @conf.install_dir)
      raise DeploymaticError.new("Cannot clone git repo '#{@conf.repo}': #{result}") unless ok

      @conf.install_commands.to_a.each do |install_command|
        result, ok = run(*install_command.split(/\s+/), within: @conf.install_dir)
        raise DeploymaticError.new("Cannot run install command '#{install_command}': #{result}") unless ok
      end

      io = StringIO.new(systemd_unit_file_to_string)
      path = unit_file_path
      on(@conf.url) do
        upload!(io, path)
      end

      result, ok = run(:systemctl, '--user', 'daemon-reload')
      raise DeploymaticError.new("Cannot reload systemd daemon: #{result}") unless ok

      result, ok = run(:systemctl, '--user', 'enable', @conf.name)
      raise DeploymaticError.new("Cannot enable systemd service '#{@conf.name}': #{result}") unless ok
    end

    def uninstall
      run(:systemctl, '--user', 'stop', @conf.name)
      run(:systemctl, '--user', 'disable', @conf.name)
      run(:rm, unit_file_path)
      run(:systemctl, '--user', 'daemon-reload')
      run(:rm, '-r', @conf.install_dir)
    end

    def deploy
      result, ok = run(:git, 'pull', within: @conf.install_dir)
      raise DeploymaticError.new("Cannot pull git repo '#{@conf.repo}': #{result}") unless ok

      @conf.install_commands.to_a.each do |install_command|
        result, ok = run(*install_command.split(/\s+/), within: @conf.install_dir)
        raise DeploymaticError.new("Cannot run install command '#{install_command}': #{result}") unless ok
      end

      restart
    end

    %w[start stop restart].each do |command|
      define_method command do
        result, ok = run(:systemctl, '--user', command, @conf.name)
        raise DeploymaticError.new("Cannot #{command} systemd service '#{@conf.name}': #{result}") unless ok
      end
    end

    def status
      result, ok = run(:systemctl, '--user', 'status', @conf.name)
      raise DeploymaticError.new("Cannot #{command} systemd service '#{@conf.name}': #{result}") unless ok

      puts result
    end

    def show
      puts systemd_unit_file_to_string
    end

    private

    def systemd_unit_file_to_string
      raw_template = File.read(File.join(__dir__, 'systemd_service_file_template.erb'))
      template = ERB.new(raw_template, trim_mode: '-')
      return template.result(@conf.instance_eval { binding })
    end

    def run(command, *, within: '.')
      result = nil
      ok = false
      on(@conf.url) do
        within(within) do
          result = capture(command, *, verbosity: Logger::INFO)
          ok = true
        rescue SSHKit::Command::Failed => e
          result = e.message
          ok = false
        end
      end
      return result, ok
    end

    def unit_file_path
      File.join(@home_dir, '.config/systemd/user', "#{@conf.name}.service").to_s
    end
  end
end
