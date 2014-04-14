require 'yaml'
require 'docker'
require 'json'

class DockerPeer
  def initialize
    @images = {}
    @containers = {}
  end

  def run(path)
    runner_conf = YAML.load_file("#{path}/test.yml")
    system_confs = runner_conf.fetch('system', [])
    test_confs = runner_conf.fetch('test', [])
    all_confs = system_confs + test_confs
    # Not threaded because it changes directories
    # Could run in separate processes, but that was awkward to make work
    all_confs.each { |conf| @images[conf['build']] = build_image(conf['name'], conf['build']) }
    system_threads = thread_containers(system_confs)
    test_threads = thread_containers(test_confs)
    # Wait for tests to complete, then tear down system
    test_threads.each { |thr| thr.join }
    system_threads.each { |thr| thr.kill_that_thing! }
  end

  private
  def build_image(name, build_path)
    puts "Building #{build_path}"
    image = Docker::Image.build_from_dir(build_path) do |line|
      puts "#{build_path}: #{JSON.parse(line)['stream']}"
    end
    image.tag repo: name
    return image
  end

  def create_container(conf, image)
    createArgs = {'Image' => image.id}
    createArgs['Cmd'] = conf['cmd'] unless conf['cmd'].nil?
    createArgs['Volumes'] = conf['volumes'] unless conf['volumes'].nil?
    createArgs['VolumesFrom'] = conf['volumes-from'].map { |vf| @containers[vf] } unless conf['volumes-from'].nil?
    return Docker::Container.create(createArgs)
  end

  def start_container(conf, container)
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

  def thread_containers(confs)
    threads = []
    confs.each do |conf|
      # Create container outside thread so we can add it to the list,
      # so we know to wait for it later
      @containers[conf['name']] = create_container(conf, @images[conf['build']])
      threads << Thread.new do
        start_and_attach(conf, @containers[conf['name']])
      end
    end
    return threads
  end
end
