require 'mixlib/shellout'

class Poller
  def initialize( gitrepo ) 
    unless (File.exists?('.app'))
      puts 'cloning .app directory'
      clone = Mixlib::ShellOut.new("git clone https://github.com/#{gitrepo} .app")
      clone.run_command
      clone.error!
      puts clone.stdout

    end
    puts 'initialized poller!!!!!'
  end  

  def poll
    poll = Mixlib::ShellOut.new("git pull", :cwd => '.app')
    poll.run_command
    unless poll.stdout.include? 'up-to-date'
      puts poll.stdout
      puts "run block"
      yield
    end
  end
end