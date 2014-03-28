require 'rufus-scheduler'
require_relative '../../lib/poller.rb'

scheduler = Rufus::Scheduler.new
poller = Poller.new 'DiUS/WasteNot'

scheduler.in '5s' do
  puts 'Hello... Rufus'
  poller.poll { puts "hello poller" }
end