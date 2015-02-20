use strict;
use warnings;
package SalattuImuri::Config;
sub parse {
	my ($self, $path) = @_;
	open(my $fh, '<', $path) or die("cannot open $path: $!");
	my $str = join('', <$fh>);
	pos($str) = 0;
	while ($str =~ m/\[([^\]]+)\]([^\[]+)/cgs) {
		my ($header, $blocks) = ($1, $2);
		if ($header =~ m/^group/i) {
			$self->doHeaderGroup($header, $blocks);
		} elsif ($header =~ m/^server/i) {
			$self->doHeaderServer($header, $blocks);
		}
	}
	
	close($fh);
}

sub new {
	my ($class) = @_;
	my $self = bless({}, $class);
	$self->{filters} = [];
	$self->{servers} = {};
	return $self;
}

sub getFilters {
	return shift->{filters};
}

sub getServers {
	return shift->{servers};
}

sub doHeaderGroup {
	my ($self, $headerSrcRes, $blocks) = @_;
	#extract header
	my @h = split(' ', $headerSrcRes);
	for my $entry (split("\n", $blocks)) {
		# skip empty lines or
		next if ($entry eq "");
		# regex = path
		$entry =~ m/(^[^\=]+)=\s*(.+)$/;
		my $filter = {
			source => $h[1],
			resolution => $h[2],
			regex => $1,
			path => $2
		};
		push @{$self->{filters}}, $filter;
	}
}

sub getServerInfo {
	my ($self, $name) = @_;
	my $info = $self->{servers}{$name};
	if (!defined $info) {
		$self->{servers}{$name} = $info = {
			server => $name,
			hostname => "",
			port => "",
			root => "",
			username => ""
		};
	}
	return $info;
}

sub doHeaderServer {
	my ($self, $header, $blocks) = @_;
	my @h = split(' ', $header);
	my $info = $self->getServerInfo($h[1]);
	for my $entry (split("\n", $blocks)) {
		next if ($entry eq "");
		$entry =~ m/(^.+?)\s*=\s*(.+)$/;
		$info->{$1} = $2;
	}
}

1;