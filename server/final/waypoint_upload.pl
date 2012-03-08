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

my $config = {};
my $config_file = $0; $config_file =~ s/\.([^\.]+)$/\.cfg/;
Config::Simple->import_from( $config_file, $config);

GetOptions (
  "path=s" => \$config->{waypoint_path},
  );

$config->{rel_identifier_separator} = '|'; #should never change. Affects Waypoints designators...

die "No waypoint path $config->{waypoint_path}" unless defined $config->{waypoint_path} && -d $config->{waypoint_path};

find( \&waypoint_file, $config->{waypoint_path} );

sub waypoint_file {
  my $filename = $_;
  my $file_fullpath = $File::Find::name;
  my $dir = $File::Find::dir;
  
  if ( $filename =~ $config->{waypoint_filename_regex} ) {
    if ( !-f $file_fullpath . $config->{upload_postfix} ||
        (stat( $file_fullpath ))[9] > (stat( $file_fullpath . $config->{upload_postfix}))[9] ) {
      #this file needs updating online
      upload( $file_fullpath );
    }
  }
}

sub upload {
  my ( $file_fullpath ) = @_;
  my ( $volume, $dir, $filename ) = File::Spec->splitpath( $file_fullpath );
  #./Waypoints/Client/Product -> Client|Product|Campaign.kmz
  my ( $rel_identifier) = join( $config->{rel_identifier_separator} ,
                               File::Spec->splitdir( File::Spec->abs2rel( $dir, $config->{waypoint_path}) ),
                               $filename);
  
  my $kml = get_kml( $file_fullpath );
  
  #store waypoints with identifier=>JSON content
  my $waypoints;
  
  print $kml;
  
  #support single Folder of waypoints per file
  warn "Weird kml format that will not be uploaded in $file_fullpath"
    unless defined $kml->{Document} && ref $kml->{Document}->{Folder} eq 'HASH' &&
    ref $kml->{Document}->{Folder}->{Placemark} eq 'ARRAY';
  
  #go into placemarks
  foreach my $waypoint ( @{$kml->{Document}->{Folder}->{Placemark}} ) {
    #skip waypoints that do not have a tag or end with a $
    next if $waypoint->{visibility} eq '0';
    #score:15\nother:C->{score=>15,other:C}
    my $description = { map split(/:/, $_ ),split(/\n/, $waypoint->{description}) };
    
    my $waypoint_data = {
      name=>$waypoint->{name},
      coordinates=>$waypoint->{Point}->{coordinates},
      properties=>$description,
    };
    #$json_text = JSON->new->utf8->encode($perl_scalar)
    #$waypoints->{} 
    print $waypoint;
  }
  
#Then sha that for WP number
}

sub get_kml {
  my ( $file_fullpath ) = shift;
  my $error = 0;

  my $kmz = Archive::Zip->new( $file_fullpath ) || $error++;
  
  my ($xml_contents, $status ) = $kmz->contents( 'doc.kml' );
  #skip unreadable
  die("Broken zip file") unless $status == AZ_OK;
  my ( $kml ) = XMLin( $xml_contents,
                      NormaliseSpace => 2,
                      KeyAttr => {'Placemark'=>undef}, #disable folding on Plaecmark->name!
                      #ValueAttr => {'polygon'=>'coordinates'},
                      ForceArray => ['Placemark'],
                      );
  return $kml;
}



#
#my $clipboard;
#my $output_file;
#
#foreach my $display ( @select_display ) {
#  $output_file .= join(",", map "\"" . $_ . "\"", @$display ) . "\n";
#  $clipboard .= join("\t", @$display ) . "\n";
#}
#
#open ( OUTPUT, '>>' . $config->{output_file} );
#
#print OUTPUT $output_file;
#Clipboard->copy( $clipboard );
#
#close ( OUTPUT );
#
#print "Output " . @select_display . " elements to " . $config->{output_file} . " and clipboard\n";
#
#sub process_displays {
#  my ( $displays, $polygon, $select_display ) = @_;
#
#  foreach my $display ( @$displays ) {
#    $display->{address} =~ m/ID\s*(\d+)/;
#    $display->{displayid} = $1;
#    $display->{style} =~  s/#//;
#  }
#
#  #process polygon
#  while ( my ($polygon_name, $coordinates) = each( %$polygon ) ) {
#    my @coordinates;
#    #split separate coordinates and kill trailing altitude above ground
#    @coordinates = map { getCoordinatesArray($_) } split(" ", $coordinates->{coordinates} );
#
#    my $polygon = Math::Polygon->new( @coordinates );
#
#    #select all displays that fit in this polygon
#    foreach my $display ( @$displays ) {
#      if ( $polygon->contains( getCoordinatesArray( $display->{coordinates} ) ) ) {
#        push @$select_display, [$display->{displayid},$display->{style},$polygon_name]
#      }
#    }
#  }
#}
#
#sub getCoordinatesArray {
#  my $coordinates = shift;
#  $coordinates =~ /([+-\.\d]+),([+-\.\d]+),([+-\.\d]+)/;
#
#  return [$1, $2];
#}
