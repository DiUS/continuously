#!/bin/bash

DOCKERID=""
CONTINUOUSLYID=""
NGROK=`command -v ngrok`
RUN_DOCKERD=0
RUN_NGROK=0

set -e

while getopts ":dnh" opts; do
  case $opt in
    d)
      RUN_DOCKERD=1
    ;;
    n)
      RUN_NGROK=1
    ;;
    h)
      echo "Usage: ${BASH_SOURCE[0]} [-d] [-n]"
      echo "[-d] runs a self-contained docker container"
      echo "[-n] runs ngrok automatically"
      exit 1
    ;;
  esac
done

trap on_exit EXIT
on_exit() {
  [ "x${DOCKERID}" == "x" ] || {
    docker kill ${DOCKERID}
    docker rm ${DOCKERID}
  }
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

run_dockerd() {
  docker build --tag="dockerd" dockerd
  DOCKERID=`docker run -d --name="dockerd" --privileged dockerd`
}

run_continuously() {
  docker build --tag="continuously" continuously
  if (( ${RUN_DOCKERD} == 1 )); then
    CONTINUOUSLYID=`docker run -d --name="continuously" --volumes-from=dockerd --link=dockerd:dockerd -p 3000:3000 continuously`
  else
    IPADDR=$(/sbin/ifconfig docker0 | grep 'inet addr' | awk 'BEGIN { FS = "[ :]+" } ; { print $4 }')
    CONTINUOUSLYID=`docker run -d --name="continuously" -v /var/git:/var/git -e DOCKERD_PORT=tcp://${IPADDR}:4243 -p 3000:3000 continuously`
  fi
}

(( ${RUN_DOCKERD} == 1 )) && run_dockerd
run_continuously
(( ${RUN_NGROK} == 1 )) && run_ngrok || docker wait continuously
