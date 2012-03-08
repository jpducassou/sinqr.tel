package Sinqrtel::SDB;

# ============================================================================
# SimpleDB handling funtions for Sinqrtel

# ============================================================================
use strict;
use warnings;

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

	$attributes = _hash_to_attributes($attributes, 'Replace', 1);

	warn Dumper($attributes);

	my $response = $sdb -> putAttributes({
		DomainName => $domain_name,
		ItemName   => $item_name,
		Attribute  => $attributes,
		Expected   => { 'Name' => 'timestamp', 'Value' => $expected_timestamp, 'Exists' => ( defined $expected_timestamp ? 'true' : 'false' ) },
	});

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
