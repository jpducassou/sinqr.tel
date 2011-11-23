#Gonzalo 23/11/2011
#Convierte archivo #hash\turl a JSON y lo sube a S3, si todo sale bien...
use strict;
use JSON::XS;
use Amazon::S3;

#configuracion
my $min_keys = 3; #minimo de claves en hash para considerar que está ok
my $access_key = 'AKIAIC2DBRTIUKHMGASQ'; # AWS Access Key ID
my $secret_key = '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'; # AWS Secret Key
#no tan configuracion
my $redir_online_bucket = 'www.sinqrtel.com';
my $redir_online_uri = 'redir.json';
my $redir_acl = '';

#realmente no es configuracion
my $redir_content_type = 'application/json';

my %redirs;

open( REDIRDB, '..\dbs\redirdb.txt');

while ( <REDIRDB> ) {
  if ( $_ =~ /^(#\w+)\s+(.+)$/ ) {
    print "Repeated: $1!\n" if ( defined $redirs{$1} );
    $redirs{$1} = $2;
  }
}

close( REDIRDB );

print 'Got ' . scalar keys ( %redirs ) . ' redirs' . "\n";

my $utf8_encoded_json_text = encode_json \%redirs;

if ( scalar keys ( %redirs ) >= $min_keys ) {
  print 'Uploading to S3...' . "\n";

  my $s3 = Amazon::S3->new( {
        aws_access_key_id     => $access_key,
        aws_secret_access_key => $secret_key,
        secure                => 0,
      }
  );

  my $bucket = $s3->bucket( $redir_online_bucket );

  $bucket->add_key(
      $redir_online_uri, $utf8_encoded_json_text , {
        content_type        => $redir_content_type,
        acl_short           => 'public-read',
      }
  );
}
