use strict;
use HTTP::Daemon;
use HTTP::Status;
use HTTP::Response;

my $counter = 1;

my $resp = new HTTP::Response( '200' );

my $d = new HTTP::Daemon;
print "Please contact me at: <URL:", $d->url, ">\n";
while (my $c = $d->accept) {
  while (my $r = $c->get_request) {
    if ($r->method eq 'GET' and $r->url->path =~ "/bid_") {
      $counter++;
      $resp->content( "{" . qq(Nelson). ":" . qq($counter) . "}" );
      # remember, this is *not* recommened practice :-)
      $c->send_response( $resp );
    } else {
      $c->send_error(RC_FORBIDDEN)
    }
  }
  $c->close;
  undef($c);
}
