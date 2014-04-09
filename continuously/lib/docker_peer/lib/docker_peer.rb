require 'yaml'
require 'docker'

class DockerPeer
  def run(path) 
    runner_conf = YAML.load_file("#{path}/test.yml")
    threads = []
    trap 'SIGTERM' do
      puts "Killing #{threads.size} threads"
      threads.each { |thr| thr.terminate }
    end
    runner_conf.fetch('system', []).each do |container_conf| 
      threads << Thread.new do
        build_path = container_conf['build']
        puts "Building #{build_path}"
        image = Docker::Image.build_from_dir(build_path)
        puts "Running #{image}"
        container = Docker::Container.create('Image' => image.id,
          'Cmd' => [container_conf['cmd']],
          'Volumes' => container_conf['volumes'],
          'VolumesFrom' => container_conf['volumes-from']) 
        container.tap(&:start).attach { |stream, chunk| puts "#{stream}: #{chunk}" }
        container.wait
        Thread.exit
      end
    end
    threads.each { |thr| thr.join }
  end
end

