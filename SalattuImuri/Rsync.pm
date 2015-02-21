use strict;
use warnings;
use 5.012;
package SalattuImuri::Rsync;
use SalattuImuri::Config;

sub new {
	my ($class, $config) = @_;
	my $self = {
		config => $config
	};
	bless $self, $class;
	return $self;
}

sub vacuum {
	my ($self) = @_;
	foreach my $serverName ( keys %{$self->{'config'}->getServers()}) {
		my $server = $self->{'config'}->getServerInfo($serverName);
	        my @files = $self->listFiles($server);
		my $i = 0;
		foreach my $filter (@{$self->{'config'}->getFilters()}) {
			my $re = "$filter->{'regex'}$filter->{'resolution'}.+$filter->{'source'}";
			my @matches = grep(/$re/i, @files);
			$self->initiateVacuuming($filter, @matches);
		}	
	}
}

sub initiateVacuuming {
	my ($self, $filter, @files) = @_;
	print join(' ', @files);	
}

sub asd {
	my $s = "rsync /path/to/file /to/file2/ -rav --partial";
}



sub listFiles {
	my ($self, $server) = @_;
	open(my $rsync_h, '-|', "rsync --list-only -e ssh $server->{'username'}"."@"."$server->{'hostname'}:$server->{'root'} ".
		'| awk \'{$1=$2=$3=$4=""; print substr($0,5); }\'') or die $!;
	my @files;
	while ( <$rsync_h>) {	
		chomp;
		push @files, $_;
	}
	close($rsync_h);
	return @files;
}

1;
