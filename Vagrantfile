# Script to create a vbox or AWS instance with pre-reqs installed
#
# For AWS, you need the following ENV variables:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_KEYPAIR_NAME (default 'aws-syd')
# SSH_PRIVKEY (default '~/.ssh/aws-syd.pem')
#
# In addition, your AWS should have a "continuously" security group available. The AWS setup
# is pretty much locked down to ap-southeast-2b atm - if you want a different region,
# you'll need change AWS_REGION and AWS_AMI, and find an appropriate image at
# http://cloud-images.ubuntu.com/locator/ec2/

# Ubuntu 13.10
AWS_REGION = 'ap-southeast-2'
AWS_AMI = 'ami-0329b739'
VBOX_NAME = "ubuntu-13.10-amd64-daily"
VBOX_URI = 'http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box'
VBOX_IP = ENV.fetch('DOCKER_IP', '10.42.42.2')
# Using Facter to give us a machine with a quarter the memory and half the cpus of host
VBOX_MEMORY = ENV.fetch('DOCKER_MEMORY', [Facter.memsize_mb.to_i/4, 512].max)
VBOX_CPUS = ENV.fetch('DOCKER_CPUS', [Facter.processorcount.to_i/2, 1].max])

# The following two methods were taken from https://github.com/mitchellh/vagrant/issues/1874
# and should be removed and replaced when Vagrantfile can manage installation of plugins.
# We do this so we can install https://github.com/dotless-de/vagrant-vbguest
# (and other plugins)
def plugin(name, version = nil, opts = {})
  @vagrant_home ||= opts[:home_path] || ENV['VAGRANT_HOME'] || "#{ENV['HOME']}/.vagrant.d"
  plugins = File.exists?("#@vagrant_home/plugins.json") ?
    JSON.parse(File.read("#@vagrant_home/plugins.json")) :
    nil

  if plugins.nil? || !plugins['installed'].include?(name) || (version && !version_matches(name, version))
    cmd = "vagrant plugin install"
    cmd << " --entry-point #{opts[:entry_point]}" if opts[:entry_point]
    cmd << " --plugin-source #{opts[:source]}" if opts[:source]
    cmd << " --plugin-version #{version}" if version
    cmd << " #{name}"
    result = %x(#{cmd})
  end
end

def version_matches(name, version)
  gems = Dir["#@vagrant_home/gems/specifications/*"].map { |spec| spec.split('/').last.sub(/\.gemspec$/,'').split(/-(?=[\d]+\.?){1,}/) }
  gem_hash = {}
  gems.each { |gem, v| gem_hash[gem] = v }
  gem_hash[name] == version
end

plugin "vagrant-vbguest"
plugin "facter"

Vagrant.configure("2") do |config|
  config.vm.provision "docker"
  config.vm.provision :shell, :path => "bootstrap.sh"
  config.vm.network :private_network, ip: VBOX_IP
  config.vm.provider :vbox do |vbox, override|
    config.vm.box = VBOX_NAME
    config.vm.box_url = VBOX_URI
    vbox.name = VBOX_NAME
    vbox.customize ["modifyvm", :id, "--memory", VBOX_MEMORY
    vbox.customize ["modifyvm", :id, "--cpus", VBOX_CPUS
    vbox.customize ["modifyvm", :id, "--cpuexecutioncap", "75"]
  end

  config.vm.provider :aws do |aws, override|
    config.vm.box = 'dummy'
    config.vm.box_url = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME'] || 'aws-syd'
    aws.region = ENV['AWS_REGION'] || AWS_REGION
    aws.instance_type = 'm1.small'
    aws.security_groups = ['continuously']
    aws.ami = ENV['AWS_AMI'] || AWS_AMI
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ENV['SSH_PRIVKEY']
  end
end
