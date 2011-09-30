#!/usr/bin/perl -w
#
# (c)2011 cr0n

use strict;
use Net::Telnet ();
use LWP::UserAgent;
use Getopt::Std;
use File::Basename;
use DBI;

my $g_timeout = 5;
my $sqlitefile = "flagsdb.sqlite";
my $file = "";

our ($opt_u, $opt_t, $opt_c, $opt_f, $opt_h, $opt_v, $opt_i, $opt_p, $opt_k, $opt_x, $opt_m);

my $mode = "telnet";
my $source = "tty";
my $host = "localhost";
my $port = 23;
my $url = "http://" . $host;
my $key = "flag";
my @x = (0,0);

getopts('m:f:t:c:vhp:u:k:ix:');

if ($opt_h) {
	printf "usage:\t%s OPTIONS ARG ...\n\t-h\t\tthis screen\n\t-f FILE\t\tread flags from FILE\n\t-i\t\tread flags from STDIN\n\t-m MODE\t\tsubmission mode (telnet|httppost)\n\t-c HOST\t\thost to connect to (telnet mode)\n\t-p PORT\t\tport to connect to (telnet mode)\n\t-u URL\t\turl to post to (httppost mode)\n\t-k KEY\t\tpost data key of key=value pair (value=flag, httppost mode)\n\t-t TIMEOUT\ttimeout in seconds for connections\n\t-v\t\tverbose mode (doesn't work :P)\n\t-x [0-3]\tread hello/response in telnet mode\n\t\t\t(0: read nothing, 1: read hello, 2: read response, 3: read both)\n", basename($0);
	exit 0;
}

my $dbh = DBI->connect("dbi:SQLite:dbname=$sqlitefile","","");

$g_timeout = $opt_t if (defined($opt_t) && $opt_t > 0);
$mode = $opt_m if defined($opt_m) && $opt_m =~ m/^(?:telnet|httppost)$/;
$source = "stdin" if $opt_i;
$host = $opt_c if defined($opt_c) && $opt_c =~ m/^[\-\w\.]+$/;
$port = $opt_p if defined($opt_p) && $opt_p =~ m/^\d+$/;
$key = $opt_k if defined($opt_k) && $opt_k =~ m/^\w+$/;
$url = $opt_u if defined($opt_u) && $opt_u =~ m#^https?://.+?$#;
if (defined($opt_f) && -f $opt_f) {
	$file = $opt_f;
	$source = "file";
}
@x = split "", unpack "b2", pack "c", $opt_x if defined($opt_x) && $opt_x =~ m/^\d+$/;

sub store_success {
	my $sth = $dbh->prepare("INSERT INTO flags (flag, timestamp) VALUES(?, datetime('now', 'localtime'));");
	$sth->execute(shift);
	$sth->finish;
}

sub submit_telnet {
	my ($what, $host, $port, $expect_hello, $expect_response) = @_;
	my $t = new Net::Telnet (Timeout => $g_timeout, Port => $port, Host => $host);
	$t->getlines(All => 0) if $expect_hello;
	my $r = $t->print($what);
	$t->getlines(All => 0) if $expect_response;
	$t->close;
	return $r;
}

sub submit_http_post {
	my ($url, $post_data) = @_;
	my $ua = LWP::UserAgent->new;
	$ua->timeout($g_timeout);
	my $r = $ua->post($url, $post_data);
	return ($r->is_success) ? 1 : die $r->status_line;
}

if ($mode eq "telnet") {
	if ($opt_i) {
		while (<STDIN>) {
			chomp;
			my $foo = $_;
			store_success($foo) if submit_telnet($foo, $host, $port, $x[0], $x[1]);
		}
	} elsif ($source eq "file") {
		open FH, "<", $file or die "couldn't open file: $!\n";
		while (<FH>) {
			chomp;
			my $foo = $_;
			store_success($foo) if submit_telnet($foo, $host, $port, $x[0], $x[1]);
		}
		close FH;
	} else {
		foreach my $foo (@ARGV) {
			store_success($foo) if submit_telnet($foo, $host, $port, $x[0], $x[1]);
		}
	}
} elsif ($mode eq "httppost") {
	if ($opt_i) {
		while (<STDIN>) {
			chomp;
			my $foo = $_;
			store_success($foo) if submit_http_post($url, [$key, $foo]);
		}
	} elsif ($source eq "file") {
		open FH, "<", $file or die "couldn't open file: $!\n";
		while (<FH>) {
			chomp;
			my $foo = $_;
			store_success($foo) if submit_http_post($url, [$key, $foo]);
		}
	} else {
		foreach my $foo (@ARGV) {
			store_success($foo) if submit_http_post($url, [$key, $foo]);
		}
	}
}

$dbh->disconnect;

exit 0;
