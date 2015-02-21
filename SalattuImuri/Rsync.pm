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
		print @files;	
	}
}

sub listFiles {
	my ($self, $server) = @_;
#	my $connectionstr = "rsync --list-only -e ssh $server->{'username'}".'@'."$server->{'hostname'}:$server->{'root'}";
	open(my $rsync_h, '-|', "rsync --list-only -e ssh $server->{'username'}"."@"."$server->{'hostname'}:$server->{'root'} ".
		'| awk \'{$1=$2=$3=$4=""; print substr($0,5); }\'') or die $!;
	my @files = <$rsync_h>;
	close($rsync_h);
	return @files;
}

1;
