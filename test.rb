#!/usr/bin/env ruby

require 'docker_peer'
Docker.url = 'tcp://127.0.0.1:4243'
runner = DockerPeer.new

runner.run('.')
