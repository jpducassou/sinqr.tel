#Gonzalo 23/11/2011
#Convierte archivo #hash\turl a JSON y lo sube a S3, si todo sale bien...
use strict;
use JSON::XS;
use Amazon::S3;
use Config::Simple;

my $config = {}; #must be empty hash for Config::Simple
my $config_file = $0; $config_file =~ s/\.([^\.]+)$/\.cfg/;
die("No config file $config_file!") unless -f $config_file;
Config::Simple->import_from( $config_file, $config);

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

if ( scalar keys ( %redirs ) >= $config->{min_keys} ) {
  print 'Uploading to S3...' . "\n";

  my $s3 = Amazon::S3->new( {
        aws_access_key_id     => $config->{access_key},
        aws_secret_access_key => $config->{secret_key},
        secure                => $config->{secure},
      }
  );

  my $bucket = $s3->bucket( $config->{redir_online_bucket} );

  if ( $bucket->add_key(
      $config->{redir_online_uri}, $utf8_encoded_json_text , {
        content_type        => $config->{redir_content_type},
        acl_short           => $config->{redir_acl},
      })
    ) {
    print "Uploaded...\n";
  } else {
    print "ERROR UPLOADING!!!\n";
  }
}
