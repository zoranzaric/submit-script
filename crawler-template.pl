#!/usr/bin/perl -I./packages/
#
# (c)2011 cr0n

use strict;
use warnings;

use CTF::Crawler::HTTP;
use CTF::Crawler::Telnet;
use Data::Dumper;

$| = 1;

sub hr($) {
	printf "--- %s ---\n", shift;
}

my $url1 = 'http://cypherpunks.cc/f00';
my $url2 = 'http://rss.golem.de/rss.php?tp=sec&feed=RSS2.0';

my $crwl = CTF::Crawler::HTTP->new(
	flag_regexp	=> "<title>(.+?)</title>",
	agent		=> "Safari.. LOL"
);

my $crwl_23 = CTF::Crawler::Telnet->new(
	timeout	=> 10
);

# use hashrefs for POST data
my $data = {
	f => "oo",
	b => "ar"
};

hr("POST / Redirect / SSL");
$crwl->post($url1, $data);
print $crwl->content;
print Dumper($crwl->redirects);

hr("GET / Find Flags");
$crwl->get($url2);
print Dumper($crwl->flags);

hr("Telnet / Find Flags");
$crwl_23->open("localhost", 23332);
#$crwl_23->readln;
#$crwl_23->writeln("foo");
$crwl_23->readall;
$crwl_23->close;
print Dumper($crwl_23->flags);

exit 0;
