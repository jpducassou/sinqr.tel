use strict;
use LWP::Simple;
use LWP::Simple::WithCache;
use Benchmark;

my ($start, $end);
my $response;

my $uri = 'http://www.sinqrtel.com/objectinfo/wp30b82c00ff3c67fc762e714870f5e5c5f650bc5d';

print "10 uncached";
$start = new Benchmark;
for (my $x=0; $x<=10; $x++) {
  $response = LWP::Simple::get( $uri );
  print '.';
}
print "\n";
$end = new Benchmark;
print timestr(timediff($end, $start),'all') . "\n";

print "10 cached";
$start = new Benchmark;
for (my $x=0; $x<=10; $x++) {
  $response = LWP::Simple::WithCache::get( $uri );
  print '.';
}
print "\n";
$end = new Benchmark;
print timestr(timediff($end, $start),'all') . "\n";

