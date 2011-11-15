# (c)2011 cr0n
package CTF::Crawler::Telnet;

use strict;
use warnings;

use Net::Telnet ();

sub new {
	my ($class, %args) = @_;
	my $flag_regexp = exists $args{flag_regexp} ? $args{flag_regexp} : '\w{31}=';
	my $timeout = exists $args{timeout} ? $args{timeout} : 10;
	my $logfile = exists $args{logfile} ? $args{logfile} : "$ENV{HOME}/.telnet-output.log";
	my $self = bless({}, $class);
	$self->{flag_regexp} = $flag_regexp;
	$self->_initialize($timeout, $logfile);
	return $self;
}

sub _initialize {
	my ($self, $timeout, $logfile) = @_;
	$self->{t} = new Net::Telnet(Timeout => $timeout);
	$self->{t}->output_log($logfile);
}

sub _find_flags {
	my $self = shift;
	my @flags = ();
	unless ($self->{flag_regexp} =~ m/\(.+?\)/) {
		$self->{flag_regexp} = "($self->{flag_regexp})";
	}
	my $c = $self->{buffer};
	while ($self->{buffer} =~ m/$self->{flag_regexp}/g) {
		push @flags, $1;
	}
	$self->{flags} = \@flags;
}

sub logging {
	my ($self, $logfile) = @_;
	$self->{t}->output_log($logfile);
}

sub open {
	my ($self, $host, $port) = @_;
	return $self->{t}->open(Host => $host, Port => $port);
}

sub close {
	my $self = shift;
	return $self->{t}->close;
}

sub login {
	my ($self, $user, $pass) = @_;
	return $self->{t}->login($user, $pass);
}

sub flags {
	my $self = shift;
	return $self->{flags};
}

sub buffer {
	my $self = shift;
	return $self->{buffer};
}

sub readall {
	my $self = shift;
	my @lines = $self->{t}->getlines(All => 0);
	$self->{buffer} = join "", @lines;
	$self->_find_flags;
	return $self->{buffer};
}

sub readln {
	my $self = shift;
	$self->{buffer} = $self->{t}->getline;
	$self->_find_flags;
	return $self->{buffer};
}	

sub writeln {
	my $self = shift;
	return $self->{t}->print(shift);
}

sub write {
	my $self = shift;
	return $self->{t}->put(shift);
}

1;
