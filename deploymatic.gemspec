require_relative 'lib/deploymatic/version'

Gem::Specification.new do |spec|
  spec.name = 'deploymatic'
  spec.version = Deploymatic::VERSION
  spec.authors = ['pioz']
  spec.email = ['epilotto@gmx.com']

  spec.summary = 'Deploy services on a Git repository using Systemd'
  spec.description = <<~DESC
    This Ruby gem streamlines the deployment and management of services within a
    Git repository by leveraging systemd. Designed to simplify the process of
    installing and updating services, the gem enables automated deployment
    operations. It integrates systemd functionalities to manage services as
    daemons, allowing for monitoring, starting, stopping, and restarting services
    directly through Git commands. Configuration is set up quickly and easily in
    a YAML file, ensuring a user-friendly experience. The configuration and use
    of this gem ensure greater operational efficiency, reducing the time and
    effort required for manual service management.
  DESC

  spec.homepage = 'https://github.com/pioz/deploymatic'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/pioz/deploymatic'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(/\Aexe\//) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'activesupport', '~> 7.1'
  spec.add_dependency 'sshkit', '~> 1.22'
end
