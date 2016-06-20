#!/bin/bash

HOSTNAME=$1

[ -z $HOSTNAME ] && echo "first argument should be hostname e.g.: $0 my-dev-env" && exit -1

CT=xrdp-2
IMG=xrdp-2


HOME_DIR=/home/dockerx

docker rm -f $CT
docker run -d \
      --hostname $HOSTNAME \
      --name $CT \
      -v $(pwd)/dockerx/.config/google-chrome:$HOME_DIR/.config/google-chrome \
      -v $(pwd)/syncthing/config:/syncthing/config \
      -v $(pwd)/data:/syncthing/data \
      -v ${PWD}/go:/$HOME_DIR/go \
      -v ${PWD}/.atom:/$HOME_DIR/.atom \
      -v ${PWD}/.f18:/$HOME_DIR/.f18 \
      -v ${PWD}/.f18:/home/docker2/.f18 \
      -v ${PWD}/.wine:/$HOME_DIR/.wine \
      -v ${PWD}/build:/build \
      -v ${PWD}/cups/printers.conf:/etc/cups/printers.conf \
       -p 33892:3389\
      $IMG


docker exec -ti $CT /bin/bash
