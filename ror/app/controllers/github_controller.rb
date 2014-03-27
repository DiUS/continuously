require 'git'
require 'docker'
require 'yaml'

class GithubController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:index]
  respond_to :json
  def index
        name = params["repository"]["name"]
        url = params["repository"]["url"]
    path = "/var/lib/continuously/#{name}"
        # Clone and/or pull
        if File.directory?(path)
                repo = Git.open(path)
                repo.pull # We should pull to the version that was pushed, here
        else
                repo = Git.clone(url, name, :path => "/var/lib/continuously/") # version?
        end

    Dir.chdir(path)
    `fig up -d -f continuously.yml`
    # Catch the results of that execution, present them somewhere
  end
end
