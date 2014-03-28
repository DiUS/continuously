require 'yaml'
require 'docker'

class DockerPeer
  def run(path) 
    runner_conf = YAML.load_file("#{path}/test.yml")
    puts runner_conf
#    runner_conf['system'].each do |container| 
#      build_path = container['build']
#      image = Docker::Image.build_from_dir(build_path)
#      Docker::Container.create('Image' => image) 
#      
#    end
  end
end

