#!/bin/bash

CONTINUOUSLYID=""
NGROK=`command -v ngrok`
RUN_NGROK=0

set -e

while getopts ":nh" opt; do
  case $opt in
    n)
      RUN_NGROK=1
    ;;
    h)
      echo "Usage: ${BASH_SOURCE[0]} [-n]"
      echo "[-d] runs a self-contained docker container"
      echo "[-n] runs ngrok automatically"
      exit 1
    ;;
  esac
done

trap on_exit EXIT
on_exit() {
  [ "x${CONTINUOUSLYID}" == "x" ] || {
    docker kill ${CONTINUOUSLYID}
    docker rm ${CONTINUOUSLYID}
  }
}

run_ngrok() {
  [ "x$NGROK" == "x" ] && {
    # Should ask where to install it
    echo "Installing ngrok to /usr/local/bin..."
    set -x
    wget -q -O - https://dl.ngrok.com/linux_386/ngrok.zip | funzip > /tmp/ngrok && chmod 755 /tmp/ngrok && sudo cp /tmp/ngrok /usr/local/bin/ngrok
    set +x
  }
  ngrok 3000
}

run_continuously() {
  docker build --tag="continuously" continuously
  CONTINUOUSLYID=`docker run -d --name="continuously" -v /var/git:/var/git -e DOCKER_HOST=${DOCKER_HOST} -p 3000:3000 continuously`
}

run_continuously
(( ${RUN_NGROK} == 1 )) && run_ngrok || docker wait continuously
