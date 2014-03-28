require 'yaml'
require 'docker'

class DockerPeer
  def run(path) 
    runner_conf = YAML.load_file("#{path}/test.yml")
    puts runner_conf
    containers = []
    runner_conf['system'].each do |container_conf| 
      build_path = container_conf['build']
      puts build_path
      puts Docker.inspect
      image = Docker::Image.build_from_dir(build_path)
      containers <<  Docker::Container.create('Image' => image.id, 'Cmd' => [container_conf['cmd']], 'Volumes' => container_conf['volumes'])#, 'VolumesFrom' => container_conf['volumes-from']) 
      containers.last.start
      puts containers.last.json
    end
    containers.each do |container|
      container.wait
    end
  end
end

