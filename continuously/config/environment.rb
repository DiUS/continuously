# Configure for docker
require 'docker'

# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Continuously::Application.initialize!
