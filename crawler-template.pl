#!/usr/bin/perl -I./packages/
#
# (c)2011 cr0n

use strict;
use warnings;

use CTF::Crawler::HTTP ();
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

exit 0;
