use SalattuImuri::Config;
use SalattuImuri::Rsync;

my $config = new SalattuImuri::Config;
$config->parse('imuri.conf');

my $imuri = new SalattuImuri::Rsync($config);
$imuri->vacuum();
