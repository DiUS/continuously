require 'yaml'
require 'docker'
require 'json'

class DockerPeer
  def initialize
    @images = {}
    @system_containers = []
    @test_containers = []
  end

  def run(path)
    runner_conf = YAML.load_file("#{path}/test.yml")
    system_confs = runner_conf.fetch('system', [])
    test_confs = runner_conf.fetch('test', [])
    all_confs = system_confs + test_confs
    # Not threaded because it changes directories
    all_confs.each { |conf| @images[conf['build']] = build_image(conf['build']) }
    thread_containers(system_confs, @system_containers)
    thread_containers(test_confs, @test_containers)
    # Wait for tests to complete, then tear down system
    @test_containers.each { |thr| thr.wait }
    @system_containers.each { |thr| thr.kill_that_thing! }
  end

  private
  def build_image(build_path)
    puts "Building #{build_path}"
    image = Docker::Image.build_from_dir(build_path) do |line|
      puts "#{build_path}: #{JSON.parse(line)['stream']}"
    end
    return image
  end

  def create_container(conf, image)
    createArgs = {'Image' => image.id}
    createArgs['Cmd'] = conf['cmd'] if !conf['cmd'].nil?
    createArgs['Volumes'] = conf['volumes'] if !conf['volumes'].nil?
    createArgs['VolumesFrom'] = conf['volumes-from'] if !conf['volumes-from'].nil?
    return Docker::Container.create(createArgs)
  end

  def start_container(conf, container)
    puts "starting #{container}"
    container.start('Privileged' => conf.fetch('privileged', false))
    return container
  end

  def attach_container(container)
    container.attach { |stream, chunk| puts "#{build_path}: #{chunk}" }
  end

  def start_and_attach(conf, container)
    start_container(conf, container)
    attach_container(container)
  end

  def thread_containers(confs, containers)
    confs.each do |conf|
      Thread.new do
        container = create_container(conf, @images[conf['build']])
        containers << container
        start_and_wait(conf, container)
      end
    end
  end
end
