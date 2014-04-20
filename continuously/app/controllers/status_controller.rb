require 'docker'

class StatusController < ActionController::Base
  def index
    Docker::Container.all.to_s
  end
end
