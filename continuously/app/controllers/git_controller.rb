require 'git'
require 'docker'

class GitController < ActionController::Base
  respond_to :json
  def create
    payload = JSON.parse(params[:payload])
    name = payload["repository"]["name"]
    url = payload["repository"]["url"]
    sha = payload["head_commit"]["id"]
    home_dir = "/var/lib/continuously"
    path = "#{home_dir}/#{name}"
    # Clone and/or pull
    if File.directory?(path)
      repo = Git.open(path)
      repo.pull # We should pull to the version that was pushed, here
    else
      repo = Git.clone(url, name, :path => home_dir) # version?
    end
    render json: {}
  end
end
