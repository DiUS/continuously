# Configure for docker
require 'docker'
Docker.url = "http://#{ENV['DOCKERD_PORT_4243_TCP_ADDR']}:#{ENV['DOCKERD_PORT_4243_TCP_PORT']}"

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Continuously::Application.initialize!
