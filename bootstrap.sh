#!/bin/bash
#
# Script to install any left-overs

set -e

# Add the lxc-docker package and other requirements
echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list
wget -q -O - https://get.docker.io/gpg | apt-key add -
apt-get update -yqq && apt-get -yq upgrade
# Docker tools
apt-get install -yq lxc-docker cgroup-lite
# Python to support fig and/or maestro
apt-get install -yq python-pip python-dev
# Things I always want
apt-get install -yq git less vim wget socat tcpdump netcat unzip

# Add user to the docker group, so we don't have to sudo everything.
# On a local vbox it's vagrant, on AWS it's ubuntu
[ $(id -u vagrant >/dev/null 2>&1) ] && gpasswd -a vagrant docker
[ $(id -u ubuntu >/dev/null 2>&1) ] && gpasswd -a ubuntu docker

# Install docker-api, currently unused but nice to have
apt-get install -yq ruby-dev
gem install docker-api

# Fix the docker conf to listen on the static interface
cat << EOF > /etc/default/docker
# Docker Upstart and SysVinit configuration file

# Customize location of Docker binary (especially for development testing).
#DOCKER="/usr/local/bin/docker"

# Use DOCKER_OPTS to modify the daemon startup options.
#DOCKER_OPTS="-dns 8.8.8.8 -dns 8.8.4.4"

# If you need Docker to use an HTTP proxy, it can also be specified here.
#export http_proxy="http://127.0.0.1:3128/"

# This is also a handy place to tweak where Docker's temporary files go.
#export TMPDIR="/mnt/bigdrive/docker-tmp"

DOCKER_OPTS="-r=true -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock"
EOF
service docker restart && sleep 1

# ngrok, because it's useful
if [ ! -e /usr/local/bin/ngrok ]; then
  wget -q -O - https://dl.ngrok.com/linux_386/ngrok.zip | funzip > /usr/local/bin/ngrok && chmod 755 /usr/local/bin/ngrok
fi

# Fig, because we're currently using that for orchestration
# Also, we need the latest version because it supports "privileged"
if [ ! -e /usr/local/bin/fig ]; then
  mkdir -p /tmp/git && cd /tmp/git && git clone https://github.com/orchardup/fig.git && cd fig && python setup.py install && rm -rf /tmp/git
fi

# Useful aliases
cat << EOF > /etc/profile.d/docker.sh
docker_run_shell () {
  docker run -i -t $1 /bin/bash
}
alias dsh=docker_run_shell
EOF
chmod +x /etc/profile.d/docker.sh

# Finally, run the daemons
cd /vagrant && fig up -d
