#!/bin/bash

#Script to copy config files to git repo.

COPY_LOCATION="/home/jordan/git/Config/"
CONFIG_FILES=("/home/jordan/.config/openbox/autostart.sh" "/home/jordan/.config/openbox/menu.xml" "/home/jordan/.config/openbox/rc.xml" "/home/jordan/.screenrc" "/home/jordan/.bashrc" "/home/jordan/.vimrc")

for FILE in ${CONFIG_FILES[@]}
do
  cp $FILE $COPY_LOCATION
done
