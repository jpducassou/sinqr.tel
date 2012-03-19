use strict;
use utf8;

use XML::Simple;
use Data::Dumper;
use Clipboard;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Config::Simple;
use Getopt::Long;
use File::Find;
use File::Spec;
use JSON::XS;
use Amazon::S3;

my $config = {};
my $config_file = $0; $config_file =~ s/\.([^\.]+)$/\.cfg/;
Config::Simple->import_from( $config_file, $config);

GetOptions (
  "kmz_path=s"      =>  \$config->{kmz_path},
  "waypoint_path=s" =>  \$config->{waypoint_path},
  "secure"          =>  \$config->{secure},
  );

check_options ( $config );

print "Checking for waypoints to upload...\n";

find( \&waypoint_file, $config->{kmz_path} );

print "Done uploading waypoints\n";

sub waypoint_file {
  my $filename = $_;
  my $file_fullpath = $File::Find::name;
  my $dir = $File::Find::dir;
  
  if ( $filename =~ $config->{waypoint_filename_regex} ) {
    #check if file exists and time of creation. If kmz is newer or confirmation does not exist we must upload
    if ( !-f $file_fullpath . $config->{upload_postfix} ||
        (stat( $file_fullpath ))[9] > (stat( $file_fullpath . $config->{upload_postfix}))[9] ) {
      print "Going to update $file_fullpath\n";
      #this file needs updating online
      my $waypoints = kmz_to_json( $file_fullpath );
      
      if ( upload( $waypoints ) ) {
        my $upload_file = IO::File->new( $file_fullpath . $config->{upload_postfix} , q{>});
        if ( -f $file_fullpath . $config->{upload_postfix} ) {
          $upload_file->close;
        } else {
          die("Could not create upload confirmation file for $file_fullpath");
        }
      }
    } else {
      #this file is up to date
      print "Skipping upto date $file_fullpath\n";
    }
  }
}

sub upload {
  my ( $waypoints ) = @_;
  
  #set up Amazon
  my $s3 = Amazon::S3->new( {
        aws_access_key_id     => $config->{access_key},
        aws_secret_access_key => $config->{secret_key},
        secure                => $config->{secure},
      }
  );
  
  #select bucket
  my $bucket = $s3->bucket( $config->{waypoint_bucket} );
  
  my @uploaded;
  
  foreach my $waypoint_identifier ( keys %{$waypoints} ) {
    #add bucket:waypoint_path:waypoint_identifier to s3
    if ( $bucket->add_key(
          $config->{waypoint_path} . $waypoint_identifier,
          $waypoints->{$waypoint_identifier},
          {
            content_type        => $config->{waypoint_content_type},
            acl_short           => $config->{waypoint_short_acl},
          })
      ) {
      push @uploaded, $config->{waypoint_path} . $waypoint_identifier;
    } else {
      #vail on any error
      last;
    }  
  }
  
  #on any error try to revert partial uploads
  if ( @uploaded < keys %{$waypoints} ) {
    foreach my $partial_upload ( @uploaded ) {
      warn "Could not delete partial $partial_upload" unless bucket->delete_key( $partial_upload );
    }
  } else {
    print "Uploaded waypoints " . @uploaded . "\n";
  }
  
  #error if we did not upload the number of waypoints we have
  return ( @uploaded == keys %{$waypoints} );
}

sub kmz_to_json {
  my ( $file_fullpath ) = @_;
  my ( $volume, $dir, $filename ) = File::Spec->splitpath( $file_fullpath );
  #./Waypoints/Client/Product -> Client|Product|Campaign.kmz
  my ( $rel_identifier) = join( $config->{rel_identifier_separator} ,
                               File::Spec->splitdir( File::Spec->abs2rel( $dir, $config->{kmz_path}) ),
                               $filename);
  
  my $kml = get_kml( $file_fullpath );
  
  #store waypoints with identifier=>JSON content
  my $waypoints;
  
  #support single Folder of waypoints per file
  warn "Weird kml format that will not be uploaded in $file_fullpath"
    unless defined $kml->{Document} && ref $kml->{Document}->{Folder} eq 'HASH' &&
    ref $kml->{Document}->{Folder}->{Placemark} eq 'ARRAY';
  
  #go into placemarks
  foreach my $waypoint ( @{$kml->{Document}->{Folder}->{Placemark}} ) {
    #skip waypoints that do not have a tag or end with a $
    next if $waypoint->{visibility} eq '0';
    #score:15\nother:C->{score=>15,other:C}
    my $description = {};
    foreach my $line ( split(/\n/, $waypoint->{description} ) ) {
      $line =~ /^\s*(\S*)\s*:\s*(\S*)\s*/;
      $description->{$1} = $2 if ( defined $2 );
    }
   
    my $waypoint_data = {
      name=>$waypoint->{name},
      coordinates=>$waypoint->{Point}->{coordinates},
      properties=>$description,
    };
    
    use Digest::SHA;
    my $digest = Digest::SHA->new('sha1');
    #sha1_hex( 'Client|Product|Campaign.kmz|Waypoint 1' )
    my $unique_identifier = $config->{waypoint_prefix} . $digest->sha1_hex( $rel_identifier . $config->{rel_identifier_separator} . $waypoint_data->{name});

    $waypoints-> { $unique_identifier } = JSON::XS->new->utf8->encode( $waypoint_data );
  }
  
  return $waypoints;
}

sub get_kml {
  my ( $file_fullpath ) = shift;
  my $error = 0;

  my $kmz = Archive::Zip->new( $file_fullpath ) || $error++;
  
  my ($xml_contents, $status ) = $kmz->contents( 'doc.kml' );
  #skip unreadable
  die("Broken zip file") unless $status == AZ_OK;
  my ( $kml ) = XMLin( $xml_contents,
                      NormaliseSpace => 1,
                      KeyAttr => {'Placemark'=>undef}, #disable folding on Plaecmark->name!
                      #ValueAttr => {'polygon'=>'coordinates'},
                      ForceArray => ['Placemark'],
                      );
  return $kml;
}

sub check_options {
  #check config and options
  die "No kmz_path $config->{kmz_path}" unless defined $config->{kmz_path} && -d $config->{kmz_path};
  die "No upload_postfix" unless defined $config->{upload_postfix};
  die "No waypoint_path" unless defined $config->{waypoint_path};
  die "Bad waypoint_path, should be like objectinfo/, no initital /, with trailing /" unless $config->{waypoint_path} =~ /^[^\/].+?\/$/;
  die "No waypoint_bucket, should be www.sinqrtel.com" unless defined $config->{waypoint_bucket};
  die "No waypoint_short_acl, should be public-read" unless defined $config->{waypoint_short_acl};
  die "No waypoint_content_type, should be application/json" unless defined $config->{waypoint_content_type};
  die "No waypoint_filename_regex, should find your kmz files" unless defined $config->{waypoint_filename_regex};
  
  #it should never change... see config
  die "Modified rel_identifier_separator, MUST be |" unless $config->{rel_identifier_separator} eq '|';
  die "Modified waypoint_prefix, should be wp" unless defined $config->{waypoint_prefix};
}