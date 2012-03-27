use strict;
use LWP::Simple;
use LWP::Simple::WithCache;
use Benchmark;

my %cache_opt = (
  'namespace' => 'lwp-cache',
  'cache_root' => File::Spec->catfile(File::HomeDir->my_home, '.cache'),
  'default_expires_in' => 600 );

my $ua = LWP::UserAgent->new;
my $ua_cached = LWP::UserAgent::WithCache->new(\%cache_opt);

my ($start, $end);
my $response;

##my $uri = 'http://www.sinqrtel.com/objectinfo/wpf4e448671516bb597ee2ebd4968334abbb9fa82a';

print "10 uncached";
$start = new Benchmark;
for (my $x=0; $x<=10; $x++) {
  $response = $ua->get( $uri );
  print '.';
}
print "\n";
$end = new Benchmark;
print timestr(timediff($end, $start),'all') . "\n";

print "10 cached";
$start = new Benchmark;
for (my $x=0; $x<=10; $x++) {
  $response = $ua_cached->get( $uri );
  print '.';
}
print "\n";
$end = new Benchmark;
print timestr(timediff($end, $start),'all') . "\n";

