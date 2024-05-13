#!/usr/bin/env ruby

require 'optparse'
require_relative '../lib/deploymatic'

COMMANDS = {
  install: 'Install the service on the remote host',
  uninstall: 'Uninstall the service',
  deploy: 'Deploy the latest version of the service',
  start: 'Start the service',
  stop: 'Stop the service',
  restart: 'Restart the service',
  status: 'Show the current status of the service',
  show: 'Display systemd unit service file of the service'
}.freeze

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "usage: #{$PROGRAM_NAME} [OPTIONS] {COMMAND}\n\n"
  opts.banner += "Options:\n"

  opts.on('-v', 'Print version') do |v|
    options[:version] = v
  end

  opts.separator ''
  opts.separator "Commands:\n"
  COMMANDS.each do |command, desc|
    opts.separator format('    %-10{command} %{desc}s', command: command, desc: desc)
  end
end

begin
  parser.parse!
rescue OptionParser::InvalidOption
  puts parser.help
  exit 1
end

if options[:version]
  puts Deploymatic::VERSION
  exit 0
end

if ARGV.size != 1
  puts parser.help
  exit 1
end

command = ARGV.first
unless COMMANDS.key?(command.to_sym)
  puts parser.help
  exit 1
end

runner = Deploymatic::Deployer.new('.matic.yml')
runner.send(command)
