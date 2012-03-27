use strict;
use utf8;

# config related
use Config::Simple;
use Getopt::Long;

# mostly traverse and kmz related
use File::Find;
use File::Spec;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use XML::Simple;

# Amazon S3 related
use JSON;
use Amazon::S3;

# Waypoint related
use WWW::Google::URLShortener;
use Digest::SHA;

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

#go into each kmz
find( \&process_waypoint_file, $config->{kmz_path} );

print "Done uploading waypoints\n";

1;

#implementation
sub process_waypoint_file {
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
      
      if ( upload_waypoints( $waypoints ) ) {
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

sub upload_waypoints {
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
  
  #prepare to shorten some uris
  my $googl  = WWW::Google::URLShortener->new( $config->{google_api_key} );
  my $digest = Digest::SHA->new( $config->{waypoint_digest} );
  #go into placemarks
  foreach my $waypoint ( @{$kml->{Document}->{Folder}->{Placemark}} ) {
    #skip waypoints that do not have a checkmark on Google Earth or end with a $
    print "Processing $waypoint->{name}\n";
    if ( $waypoint->{visibility} eq '0' || $waypoint->{name} =~ /\$$/ ) {
      print "Skipping invisible $waypoint->{name}\n";
      next;
    }
    #score:15\nother:C->{score=>15,other=>C}
    my $description = {};
    foreach my $line ( split(/\n/, $waypoint->{description} ) ) {
      next unless $line =~ /^\s*(\S*?)\s*:\s*(\S*)\s*$/;
      $description->{$1} = $2 if ( defined $2 );
    }

    #sha1_hex( 'Client|Product|Campaign.kmz|Waypoint 1' )
    $digest->reset();
    $digest->add( $rel_identifier . $config->{rel_identifier_separator} . $waypoint->{name} );
    my $unique_identifier = $config->{waypoint_prefix} . $digest->hexdigest();
    
    #shorten something like http://www.sinqrtel.com/#wpca4545f334234d465e
    my $waypoint_uri = $googl->shorten_url( $config->{waypoint_landing_path} . $unique_identifier );
    
    #split coordinates
    my ($waypoint_lon, $waypoint_lat, $waypoint_alt) = split(/,/, $waypoint->{Point}->{coordinates});
    #relocate score
    my ($waypoint_score) = $description->{score};
    delete $description->{score};
    
    #consolidated waypoint payload
    my $waypoint_data = {
      id=>$unique_identifier,
      name=>$waypoint->{name},
      uri=>$waypoint_uri,
      score=>$waypoint_score,
      coordinates=>{
        lon=>$waypoint_lon,
        lat=>$waypoint_lat,
        alt=>$waypoint_alt,
      },
      properties=>$description,
    };
    
    #check we have a nice waypoint
    warn "Waypoint name not recommended" unless $waypoint_data->{name} =~ /\w[\d\w\s]+/;
    warn "Waypoint coordinates misformed" unless $waypoint->{Point}->{coordinates} =~ /\-?\d+\.?\d*,\-?\d+\.?\d*,\-?\d+\.?\d*/;
    warn "Waypoint coordinates->lon misformed" unless $waypoint_data->{coordinates}->{lon} =~ /^[+-]?\d+\.?\d*$/;
    warn "Waypoint coordinates->lat misformed" unless $waypoint_data->{coordinates}->{lat} =~ /^[+-]?\d+\.?\d*$/;
    warn "Waypoint coordinates->alt misformed" unless $waypoint_data->{coordinates}->{alt} =~ /^[+-]?\d+\.?\d*$/;
    warn "Waypoint score misformed" unless $waypoint_data->{score} =~ /^[+-]?\d+$/;
    
    #more complex checks...
    warn "Waypoint coordinates->lon not from Uruguay..." unless $waypoint_data->{coordinates}->{lon} > $config->{waypoint_max_lon} || $waypoint_data->{coordinates}->{lon} < $config->{waypoint_min_lon};
    warn "Waypoint coordinates->lat not from Uruguay..." unless $waypoint_data->{coordinates}->{lat} > $config->{waypoint_max_lat} || $waypoint_data->{coordinates}->{lat} < $config->{waypoint_min_lat};
    warn "Waypoint coordinates->alt below sea level..." unless $waypoint_data->{coordinates}->{alt} <= 0;
    warn "Waypoint coordinates->alt too high..." unless $waypoint_data->{coordinates}->{alt} >= $config->{coordinates_max_alt};
    
    $waypoints-> { $unique_identifier } = JSON->new->utf8->encode( $waypoint_data );
  }
  
  return $waypoints;
}

#get kml from kmz->doc.kml file
sub get_kml {
  my ( $file_fullpath ) = shift;
  my $error = 0;

  my $kmz = Archive::Zip->new( $file_fullpath ) || $error++;
  
  my ($xml_contents, $status ) = $kmz->contents( 'doc.kml' );
  #skip unreadable
  die("Broken zip file") unless $status == AZ_OK;
  my ( $kml ) = XMLin( $xml_contents,
                      NormaliseSpace => 1,
                      KeyAttr => {
                                  'Placemark'=>undef
                                  }, #disable folding on Placemark->name!
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