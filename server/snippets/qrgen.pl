use strict;
use warnings;
use WWW::Google::URLShortener;
use LWP::Simple;

my $api_key = '';
my $google  = WWW::Google::URLShortener->new($api_key);
my $short_url = $google->shorten_url('http://www.yahoo.com');

my $png = get($short_url . '.qr');

print $png;

