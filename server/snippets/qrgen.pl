use strict;
use warnings;
use WWW::Google::URLShortener;

my $api_key = 'Your_API_Key';
my $google  = WWW::Google::URLShortener->new($api_key);
print $google->shorten_url('http://www.google.com');
