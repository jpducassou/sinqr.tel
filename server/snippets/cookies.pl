use strict;
use CGI;

my $p = new CGI;

print $p->header;

my @cookies = $p->cookie();

foreach my $cookie_name ( @cookies ) {
  print join(" ", $cookie_name, $p->cookie( -name => $cookie_name ) ) . "\n";
}
