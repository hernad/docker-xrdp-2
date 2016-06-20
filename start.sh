#!/bin/bash

SYNCTHING_USER=dockerx

HOME_DIR=/home/$SYNCTHING_USER
DOT_TGZ=/syncthing/data/configs/$(hostname)/${SYNCTHING_USER}_dot.tar.gz
if [ -f $DOT_TGZ ] ; then
  cd $HOME_DIR
  tar xzf $DOT_TGZ
fi

WINE_TGZ=/syncthing/data/configs/$(hostname)/${SYNCTHING_USER}_wine.tar.gz
if [ ! -d $HOME_DIR/.wine ] && [ -f $WINE_TGZ ] ; then
  cd $HOME_DIR
  tar xzf $WINE_TGZ
fi

FIREFOX_TGZ=/syncthing/data/configs/$(hostname)/${SYNCTHING_USER}_firefox.tar.gz
if [ ! -d $HOME_DIR/.mozilla ] && [ -f $FIREFOX_TGZ ] ; then
  cd $HOME_DIR
  tar xzf $FIREFOX_TGZ
fi

ATOM_TGZ=/syncthing/data/configs/$(hostname)/${SYNCTHING_USER}_atom.tar.gz
if [ ! -d $HOME_DIR/.atom ] && [ -f $ATOM_TGZ ] ; then
  cd $HOME_DIR
  tar xzf $ATOM_TGZ
fi

CUPS_PRINTERS=/syncthing/data/configs/$(hostname)/etc/cups/printers.conf
if [ -f $CUPS_PRINTERS ] ; then
   cp $CUPS_PRINTERS /etc/cups/
   service cups restart 
fi


chown -R $SYNCTHING_USER:$SUNCTHING_USER /home/$SYNCTHING_USER

SYNCTHING_GZ=/syncthing/config/syncthing.gz

if [ -f $SYNCTHING_GZ ] ; then
  cd /syncthing/bin
  cp $SYNCTHING_GZ .
  mv syncthing syncthing.old
  gunzip syncthing.gz
fi

# if this if the first run, generate a useful config
[ -f /syncthing/config/config.xml ] && exit 0


CONFIG=/syncthing/config/config.xml

echo "generating config"
/syncthing/bin/syncthing --generate="/syncthing/config"
# don't take the whole volume with the default so that we can add additional folders
sed -e "s/id=\"default\" path=\"\/root\/Sync\/\"/id=\"default\" path=\"\/home\/$SYNCTHING_USER\/syncthing_default\/\"/" -i $CONFIG
# ensure we can see the web ui outside of the docker container
sed -e "s/<address>127.0.0.1:8384/<address>0.0.0.0:8384/" -i $CONFIG

chown $SYNCTHING_USER.users -R /syncthing

