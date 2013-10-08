package Ubic::Service::Hypnotoad;
# ABSTRACT: Ubic service module for Mojolicious Hypnotoad

use strict;
use warnings;

use parent qw(Ubic::Service::Skeleton);

use Ubic::Result qw(result);


sub new {
	my ($class, %opt) = @_;

	my $bin = $opt{'bin'} // 'hypnotoad';
	length $bin	or die "missing 'bin' parameter in new";
	my $app = $opt{'app'} // '';
	length $app	or die "missing 'app' parameter in new";
	my $pid_file = $opt{'pid_file'} // '';
	length $pid_file	or die "missing 'pid_file' parameter in new";

	if (my $env = $opt{'env'}) {
		%ENV = (%ENV, %$env);
	}

	return bless {
		pid_file => $pid_file,
		app => $app,
		bin => $bin,
	}, $class;
}

sub _read_pid {
	my $self = shift;

	return eval {
		open my $fh, $self->{'pid_file'}	or die;
		my $pid = (scalar(<$fh>) =~ /(\d+)/g)[0];
		close $fh;
		$pid;
	};
}

sub status_impl {
	my $self = shift;

	my $pid = $self->_read_pid	or return result('not running');

	my ($i, $running, $old_pid) = (0);
	do {
		$i++;
		$old_pid = $pid;
		$running = kill 0, $old_pid;
		$pid = $self->_read_pid		or return result('not running');
	} until ($pid == $old_pid or $i > 5);

	$pid == $old_pid	or return result('broken');

	return $running ? result('running', 'pid '.$pid) : result('not running');
}

sub start_impl {
	my $self = shift;

	system($self->{'bin'}, $self->{'app'});

	return result('starting');
}

sub stop_impl {
	my $self = shift;

	system($self->{'bin'}, '-s', $self->{'app'});

	return result('stopping');
}

sub custom_commands { qw/ deploy / };

sub do_custom_command {
	my ($self, $command) = @_;

	if ($command eq 'deploy') {
		my $pid = $self->_read_pid	or return 'not running';
		my $ret = kill "USR2", $pid;
		return $ret ? 'running' : 'not running';
	} else {
		die "Unknown command '$command'"; # should never happen
	}
}


1;
