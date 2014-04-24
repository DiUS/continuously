require 'docker'

class StatusController < ActionController::Base
  def index
    @docker_containers = Docker::Container.all.to_s
  end
end
