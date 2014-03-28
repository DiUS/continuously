require 'rufus-scheduler'
require_relative '../../lib/poller.rb'

scheduler = Rufus::Scheduler.new
poller = Poller.new 'DiUS/continuously-test'

scheduler.every '5s' do
  puts 'Hello... Rufus'
  poller.poll { 
    docker = Mixlib::ShellOut.new("docker build -t hackday .app", :cwd => '.') 
    docker.run_command
    puts docker.stdout

    puts docker.stderr

    puts 'Docker created maybe???'
  }
end