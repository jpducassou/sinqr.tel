package Sinqrtel::SDB;

# ============================================================================
# SimpleDB handling funtions for Sinqrtel

# ============================================================================
use strict;
use warnings;
use Carp;

# ============================================================================
use Data::Dumper;

# ============================================================================
use Amazon::SimpleDB::Client;

# ============================================================================
require Exporter;
use vars qw($VERSION @ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(get_attributes put_attributes_conditional);


# ============================================================================
sub get_attributes {
  my ($sdb, $domain_name, $item_name) = @_;

  my $response = $sdb -> getAttributes({
    DomainName => $domain_name,
    ItemName   => $item_name,
  });

  my $attribute_list = $response -> getGetAttributesResult -> getAttribute;

	my $attributes;
	$attributes -> { $_ -> getName } = $_ -> getValue
    for @$attribute_list;

	return $attributes;
}

sub put_attributes_conditional {
  my ($sdb, $domain_name, $item_name, $attributes, $expected_timestamp) = @_;

	my $request_attributes = _hash_to_attributes($attributes, 'Replace', 1);

	my $request = {
		DomainName => $domain_name,
		ItemName   => $item_name,
		Attribute  => $request_attributes,
	};

	#only expect timestamp for values $item_names that exist (and have a timestamp > 0)
	if ( $expected_timestamp > 0) {
		$request->{Expected} = { 'Name' => 'timestamp', 'Value' => $expected_timestamp, 'Exists' => 'true'};
	}

	warn Dumper( $request );

	my $response = 1;
	eval {
		$sdb -> putAttributes( $request );
	};
	#get exceptions
	my $ex = $@;
	if ($ex) {
		require Amazon::SimpleDB::Exception;
		if (ref $ex eq "Amazon::SimpleDB::Exception") {
			if ($ex->{_errorCode} eq 'ConditionalCheckFailed') {
				$response = 0;
			} else {
				#unknown error, we are unworthy of this cpu time
				croack $@;
			}
		} else {
			#unknown exception type, this is really bad...
			croack $@;
		}
	}

	return $response;
}

sub _hash_to_attributes {
  my ($values, $condition_name, $condition_value) = @_;

  my @attributes = ();

  for my $name ( keys %$values ) {
    my $value = $values -> { $name };

    push @attributes, {
      Name                      => $name,
      Value                     => $value,
      ($condition_value ? ($condition_name => $condition_value ? 'true' : '') : ()),
    };
  }
  return \@attributes;
}

# ============================================================================

1;
