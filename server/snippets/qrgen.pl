use strict;
use warnings;
use WWW::Google::URLShortener;
use LWP::Simple;

my $api_key = '';
my $google  = WWW::Google::URLShortener->new($api_key);
print $google->shorten_url('http://www.yahoo.com');

  use WWW::Shorten::Googl;
  use WWW::Shorten 'Googl';

my $short_url = makeashorterlink('http://www.google.com');

print $short_url;

my $png = get($short_url . '.qr');

print $png;

