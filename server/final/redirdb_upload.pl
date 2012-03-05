#Gonzalo 23/11/2011
#Convierte archivo #hash\turl a JSON y lo sube a S3, si todo sale bien...
use strict;
use JSON::XS;
use Amazon::S3;
use Config::Simple;
use IO::File;

#calculate config file name
my $config = {}; #must be empty hash for Config::Simple
my $config_file = $0; $config_file =~ s/\.([^\.]+)$/\.cfg/;
die("No config file $config_file!") unless -f $config_file;

#read config file
Config::Simple->import_from( $config_file, $config);
die("No redir database at " . $config->{redirdb_file}) unless -f $config->{redirdb_file};

my %redirs;

#read file to hash
#*could be better, stream to file line by line and use S3 add_key_file which also streams
my $redirdb = IO::File->new( $config->{redirdb_file}, q{<} ); #open redirdb for red

while ( <$redirdb> ) {
  if ( $_ =~ /^(#\w+)\s+(.+)$/ ) {
    #warn on repeated redirs, use last definition
    print "Repeated: $1!\n" if ( defined $redirs{$1} );
    $redirs{$1} = $2;
  }
}

$redirdb->close;

#account for available keys
print 'Got ' . scalar keys ( %redirs ) . ' redirs' . "\n";

my $utf8_encoded_json_text = encode_json \%redirs;

#check if we have a reasonable number of keys
if ( scalar keys ( %redirs ) >= $config->{min_keys} ) {
  print 'Uploading to S3...' . "\n";

  #set up Amazon
  my $s3 = Amazon::S3->new( {
        aws_access_key_id     => $config->{access_key},
        aws_secret_access_key => $config->{secret_key},
        secure                => $config->{secure},
      }
  );

  #select bucket
  my $bucket = $s3->bucket( $config->{redir_online_bucket} );

  #create file with redirs as JSON map
  if ( $bucket->add_key(
      $config->{redir_online_uri}, $utf8_encoded_json_text , {
        content_type        => $config->{redir_content_type},
        acl_short           => $config->{redir_acl},
      })
    ) {
    print "Uploaded with no errors\n";
  } else {
    print "ERROR UPLOADING!!!\n";
  }
} else {
  print "ERROR, NOT ENOUGH KEYS. CHECK FILE\n"
}
