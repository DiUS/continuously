#!/bin/bash

set -e
trap on_exit EXIT

DOCKERID=""
CONTINUOUSLYID=""
NGROK=`which ngrok`

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

install_ngrok() {
  [ "x$NGROK" == "x" ] && {
    # Should ask where to install it
    echo "Installing ngrok to /usr/local/bin..."
    set -x
    wget -q -O - https://dl.ngrok.com/linux_386/ngrok.zip | funzip > /usr/local/bin/ngrok && chmod 755 /usr/local/bin/ngrok
    set +x
  }
}

docker build --tag="dockerd" dockerd
docker build --tag="continuously" continuously
DOCKERID=$(docker run -d --name="dockerd" --privileged dockerd)
CONTINUOUSLYID=$(docker run -d --name="continuously" --volumes-from=dockerd --link=dockerd:dockerd -p 3000:3000 continuously)
ngrok 3000
