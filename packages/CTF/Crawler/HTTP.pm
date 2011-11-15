# (c)2011 cr0n
package CTF::Crawler::HTTP;

use strict;
use warnings;

use LWP::UserAgent;

sub new {
	my ($class, %args) = @_;
	my $agent = exists $args{agent} ? $args{agent} : "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:8.0) Gecko/20100101 Firefox/8.0";
	my $timeout = exists $args{timeout} ? $args{timeout} : 10;
	my $cookies = exists $args{cookies} ? $args{cookies} : "$ENV{HOME}/.cookies.store";
	my $proxy = exists $args{proxy} ? $args{proxy} : undef;
	my $flag_regexp = exists $args{flag_regexp} ? $args{flag_regexp} : '\w{31}=';
	my $self = bless({}, $class);
	$self->{flag_regexp} = $flag_regexp;
	$self->_initialize($agent, $timeout, $cookies, $proxy);
	return $self;
}

sub _initialize {
	my ($self, $agent, $timeout, $cookies, $proxy) = @_;
	$self->{ua} = LWP::UserAgent->new;			# voodoo
	push @{$self->{ua}->requests_redirectable}, 'POST';	# make POST requests redirectable
	$self->{ua}->timeout($timeout);
	$self->{ua}->agent($agent);
	$self->{ua}->cookie_jar({file => $cookies});		# enable cookie jar
	if (defined($proxy)) {
		$self->{ua}->proxy("http", $proxy);		# set http proxy if necessary
	}
}

sub redirects {
	my $self = shift;
	my %redirs = map {$_->header("location") => $_->code} $self->{response}->redirects;
	return \%redirs;
}

sub flags {
	my $self = shift;
	return $self->{flags};
}

sub content {
	my $self = shift;
	return $self->{response}->decoded_content;
}

sub type {
	my $self = shift;
	return $self->{response}->content_type;
}

sub status {
	my $self = shift;
	return $self->{response}->status_line;
}

sub _find_flags {
	my $self = shift;
	my @flags = ();
	unless ($self->{flag_regexp} =~ m/\(.+?\)/) {
		$self->{flag_regexp} = "($self->{flag_regexp})";
	}
	my $c = $self->{response}->decoded_content;
	while ($c =~ m/$self->{flag_regexp}/g) {
		push @flags, $1;
	}
	return \@flags;
}

sub get {
	my ($self, $url, $filename) = @_;
	my $response;
	if (defined($filename) && $filename ne "") {
		$response = $self->{ua}->get($url, ':content_file' => $filename);
	} else {
		$response = $self->{ua}->get($url);
	}
	$self->{response} = $response;
	if ($response->is_success) {
		$self->{flags} = $self->_find_flags;
	}
}

sub post {
	my ($self, $url, $postdata, $filename, $content_type) = @_;
	unless (defined($content_type) && $content_type ne "") {
		$content_type = "application/x-www-form-urlencoded";
	}
	my $response;
	if (defined($filename) && $filename ne "") {
		$response = $self->{ua}->post($url, ':content_file' => $filename, Content_Type => $content_type, Content => $postdata);
	} else {
		$response = $self->{ua}->post($url, Content_Type => $content_type, Content => $postdata);
	}
	$self->{response} = $response;
	if ($response->is_success) {
		$self->{flags} = $self->_find_flags;
	}
}

1;
