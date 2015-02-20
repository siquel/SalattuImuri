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
		}
	}
	
	close($fh);
}

sub new {
	my ($class) = @_;
	my $self = bless({}, $class);
	$self->{filters} = [];
	return $self;
}

sub doHeaderGroup {
	my ($self, $headerSrcRes, $blocks) = @_;
	#extract header
	my @h = split(' ', $headerSrcRes);
	for my $entry (split("\n", $blocks)) {
		# skip empty lines or
		next if ($entry eq "");
		# regex = path
		$entry =~ m/(^[^\=]+)=(.+)$/;
		my $filter = {
			source => $h[1],
			resolution => $h[2],
			regex => $1,
			path => $2
		};
		push @{$self->{filters}}, $filter;
	}
}

1;