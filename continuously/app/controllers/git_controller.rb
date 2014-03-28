class GitController < ActionController::Base
  def create
    push = JSON.parse(params[:payload])
    puts "I got some JSON: #{push.inspect}"
    render json: {}
  end
end
