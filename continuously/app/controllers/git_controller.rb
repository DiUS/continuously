require 'git'

class GitController < ActionController::Base
  respond_to :json
  def create
    payload = JSON.parse(params[:payload])
    name = payload["repository"]["name"]
    url = payload["repository"]["url"]
    sha = payload["head_commit"]["id"]
    home_dir = "/var/containers"
    repo_dir = "#{home_dir}/#{name}"
    # Clone and/or pull
    if File.directory?(repo_dir)
      repo = Git.open(repo_dir)
      repo.pull # We should pull to the version that was pushed, here
    else
      repo = Git.clone(url, name, :path => home_dir) # version?
    end
    # docker
    DockerPeer.new.run(repo_dir)

    render json: {}
  end
end
