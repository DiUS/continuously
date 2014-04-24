require 'yaml'
require 'docker'
require 'json'

class DockerPeer
  def initialize
    @images = {}
    @containers = {}
  end

  def run(path)
    runner_conf = (File.exists?(path) && YAML.load_file("#{path}") || YAML.load_file("#{path}/test.yml"))
    system_confs = runner_conf.fetch('System', [])
    test_confs = runner_conf.fetch('Test', [])
    all_confs = system_confs + test_confs
    # Not threaded because it changes directories
    # Could run in separate processes, but that was awkward to make work
    all_confs.each { |conf| @images[conf['Build']] = build_image(conf['Name'], conf['Build']) }
    system_threads = thread_containers(system_confs)
    test_threads = thread_containers(test_confs)
    # Wait for tests to complete, then tear down system
    test_threads.each { |thr| thr.join }
    system_threads.each { |thr| thr.kill_that_thing! }
    # Collect the logs and report them somewhere
  end

  private
  def build_image(name, build_path)
    puts "Building #{build_path}"
    image = Docker::Image.build_from_dir(build_path) do |line|
      output = JSON.parse(line)['stream']
      puts "#{build_path}: #{output}" unless output.nil?
    end
    image.tag repo: name
    return image
  end

  def args_from_conf(conf)
    createArgs = {'Image' => @images[conf['Build']].id}
    createArgs['Cmd'] = conf['Cmd'].split unless conf['Cmd'].nil?
    createArgs['Volumes'] = conf['Volumes'] unless conf['Volumes'].nil?
    createArgs['VolumesFrom'] = conf['VolumesFrom'].map { |vf| @containers[vf] } unless conf['VolumesFrom'].nil?
    return createArgs
  end

  def create_container(conf)
    @containers[conf['Name']] = Docker::Container.create(args_from_conf(conf))
  end

  def start_container(conf)
    @containers[conf['Name']].start('Privileged' => conf.fetch('Privileged', false))
    return @containers[conf['Name']]
  end

  def wait_for(container)
    while true
      begin
        container.wait
      rescue Docker::Error::TimeoutError
      end
    end
  end

  def start_and_wait(conf)
    wait_for(start_container(conf))
  end

  def thread_containers(confs)
    threads = []
    confs.each do |conf|
      # Create container outside thread so we can add it to the list,
      # so we know to wait for it later
      create_container conf
      threads << Thread.new do
        start_and_wait conf
      end
    end
    return threads
  end
end
