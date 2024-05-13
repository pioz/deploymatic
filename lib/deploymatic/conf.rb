require 'active_support/core_ext/string/inflections'

module Deploymatic
  class InvalidConfValueError < StandardError; end

  Conf = Struct.new(
    :name,
    :ssh_user,
    :ssh_host,
    :ssh_port,
    :repo,
    :install_dir,
    :install_commands,
    :start_command,
    :stop_command,
    :log_path,
    :run_after,
    :start_limit_burst,
    :start_limit_interval_seconds,
    :enviroment_variables
  ) do
    def initialize(**args)
      super(**args)
      self.name = self.name.parameterize
      self.install_dir ||= "$HOME/#{self.name}"
    end

    def check_required_fields
      %i[name ssh_user ssh_host repo start_command install_dir].select do |field|
        self.send(field).nil?
      end
    end

    def check_required_fields!
      fields = check_required_fields
      case fields.size
      when 0
        nil
      when 1
        raise InvalidConfValueError.new("Invalid conf value: #{fields.first} is not valid.")
      else
        raise InvalidConfValueError.new("Invalid conf values: #{fields.join(', ')} are not valid.")
      end
    end

    def url
      url = "#{self.ssh_user}@#{ssh_host}"
      url += ":#{self.ssh_port}" if self.ssh_port
      return url
    end
  end
end
