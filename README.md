# Deploymatic

Deploymatic is a Ruby tool for deploying services on a remote host using Git and systemd. It automates the installation, deployment, and management of services, making it easier to maintain and operate your applications.

## Installation

Clone the repository and install the required gems:

```bash
gem install deploymatic
```

## Configuration

Create a configuration file `.matic.yml` in the root of your project with the following structure:

```yaml
name: meteo_station_example
ssh_user: pioz
ssh_host: 192.168.0.243
ssh_port: 22 # Optional, default 22
repo: https://github.com/pioz/meteo_station_example.git
install_dir: /home/pioz/meteo_station_example # Optional, default $HOME/<service_name>
install_commands: # Optional
  - bundle install
  - rake db:migrate
start_command: bundle exec puma -C config/puma.rb
stop_command: pkill -f puma # Optional
log_path: /path/to/log/file # Optional
run_after: network-online.target # Optional
start_limit_burst: 5 # Optional
start_limit_interval_seconds: 10 # Optional
environment_variables: # Optional
  - RAILS_ENV=production
  - SECRET_KEY_BASE=your_secret_key
```

## Usage

Use `deploymatic` to manage your service. The available commands are:

- **install**: Install the service on the remote host
- **uninstall**: Uninstall the service
- **deploy**: Deploy the latest version of the service
- **start**: Start the service
- **stop**: Stop the service
- **restart**: Restart the service
- **status**: Show the current status of the service
- **show**: Display the systemd unit service file of the service

### Example

```bash
deploymatic install
deploymatic start
```

## Contributing

1. Fork it (https://github.com/pioz/deploymatic/fork)
2. Create your feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a new Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or suggestions, please open an issue.
