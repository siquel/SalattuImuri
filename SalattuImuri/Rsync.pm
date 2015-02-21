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
		foreach my $filter (@{$self->{'config'}->getFilters()}) {
			my $re = "$filter->{'regex'}$filter->{'resolution'}.+$filter->{'source'}";
			my @matches = grep(/$re/i, @files);
			$self->initiateVacuuming($server, $filter, @matches);
		}	
	}
}

sub initiateVacuuming {
	my ($self, $server, $filter, @files) = @_;
	#build rsync command
	my $c = "rsync -rav --partial --progress --protect-args -e ssh ";
	$c .= "$server->{'username'}".'@'."$server->{'hostname'}:\"$server->{'root'}".join("\" :\"$server->{'root'}", @files)."\" $filter->{'path'}";
#	print $c;# IMMA CHARGIN MAH LAZER
	system($c);	
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
