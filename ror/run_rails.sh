#!/bin/bash
#
# Set some environment variables and run rails

# Carry across the docker location
export DOCKER_HOST=$dockerd_PORT

exec rails s
