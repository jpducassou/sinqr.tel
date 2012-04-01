package Sinqrtel::SDB;

# ============================================================================
# SimpleDB handling funtions for Sinqrtel

# ============================================================================
use strict;
use warnings;
use Carp qw( croak );
use Log::Log4perl qw/:easy/;

# ============================================================================
use Data::Dumper;

# ============================================================================
use Amazon::SimpleDB::Client;

# ============================================================================
require Exporter;
use vars qw($VERSION @ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(get_attributes put_attributes select_attributes);


# ============================================================================
sub get_attributes {
  my ($sdb, $domain_name, $item_name) = @_;

	my $logger = Log::Log4perl -> get_logger();
	my $attributes;

	eval {
		my $response = $sdb -> getAttributes({
			DomainName => $domain_name,
			ItemName   => $item_name,
		});

		my $attribute_list;

		if ( defined $response ) {
			$attribute_list = $response -> getGetAttributesResult -> getAttribute;
		}

		if ( ref $attribute_list eq 'ARRAY' ) {
			$attributes -> { $_ -> getName } = $_ -> getValue for @$attribute_list;
		}
	};
	# Get the exceptions
	my $ex = $@;
	if ($ex) {
		require Amazon::SimpleDB::Exception;
		if (ref $ex eq "Amazon::SimpleDB::Exception") {
			$logger -> logcarp($@);
		} else {
			$logger -> logcarp($@);
		}
	}

	return $attributes;
}

sub put_attributes {
  my ($sdb, $domain_name, $item_name, $attributes, $expected) = @_;

	my $logger = Log::Log4perl -> get_logger();
	my $request_attributes = _hash_to_attributes($attributes, 'Replace', 1);

	my $request = {
		DomainName => $domain_name,
		ItemName   => $item_name,
		Attribute  => $request_attributes,
	};

	#only expect something if we where told to)
	if ( defined $expected ) {
		$request -> {Expected} = $expected;
	}

	# warn Dumper( $request );

	my $response = 1;
	eval {
		$sdb -> putAttributes( $request );
	};
	# Get the exceptions
	my $ex = $@;
	if ($ex) {
		require Amazon::SimpleDB::Exception;
		if (ref $ex eq 'Amazon::SimpleDB::Exception') {
			if ($ex -> {_errorCode} eq 'ConditionalCheckFailed') {
				# Just in case we check for more states in the future
				$response = 0;
			} else {
				# Unknown exception type, this is shamefull...
				$logger -> logcarp($@);
			}
		} else {
			#unknown error, we are unworthy of this cpu time
			$logger -> logcarp($@);
		}
	}

	return $response;
}

sub select_attributes {
  my ($sdb, $select_expression, $next_token) = @_;

	my $logger = Log::Log4perl -> get_logger();
	my $response;

	eval {
		$response = $sdb -> select({
			SelectExpression                        => $select_expression,
			($next_token        ? (NextToken        => $next_token)          : ()),
		});
		1;
	} or do {
		$logger -> logdie($@ -> getMessage());
	};

	my $item_list = $response -> getSelectResult -> getItem;

	my @result = map { [ $_ -> getName, _attributes_to_hash($_ -> getAttribute)  ]  } @$item_list;
	return \@result;

}

sub batch_delete_attributes {
	my ( $sdb, $domain_name, $delete_items ) = @_;
	#$delete_items = {
	#	"item_name" => {attribute_name=>'attribute_value'}, #delete by condition
	#	"item_name" => undef, #delete by item_name
	#}
	my $logger = Log::Log4perl -> get_logger();

	my $max_delete_items = 25; #documented at http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_BatchDeleteAttributes.html
	my $max_delete_attributes = 256; #documented at http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_BatchDeleteAttributes.html
	my @delete_items;

	my @request_parameters;
	#do for all $delete_items
	while ( keys %$delete_items > 0 ) {
		#split in buckets of max allowed deletes or left keys
		my $item_count = 1;
		while ( $item_count <= $max_delete_items && keys %$delete_items > 0 ) {
			my ( $item_name, $attributes ) = _hash_pop( $delete_items );
			#documented docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_DeleteAttributes.html#SDB_API_BatchPutAttributes_RequestParameters
			push @request_parameters, 'Item.' . $item_count . 'ItemName=' . $item_name;
			if ( defined $attributes ) {
				$logger -> logdie("Too many parameters to an item_name on call to BatchDeleteAttributes for $item_name") if ( scalar keys %$attributes > $max_delete_attributes );
				my $attribute_count = 1;
				while ( keys %$attributes > 0 ) {
					my ( $attribute_name, $attribute_value ) = _hash_pop( $attributes );
					push @request_parameters, 'Item.' . $item_count . 'Attribute.' . $attribute_count . 'Name=' . $attribute_name;
					push @request_parameters, 'Item.' . $item_count . 'Attribute.' . $attribute_count . 'Value=' . $attribute_value;
					$attribute_count++;
				}
			}
			$item_count++;
		}
		#make call!
	}
}

sub _hash_pop {
	my $hash = shift;
	#fast get any key from hash
	#documented http://www.perlmonks.org/?node_id=779281
	scalar keys %$hash; #reset each in scalar context, very fast!
	my ( $key, $value ) = each( %$hash ); #get one key and value from hash

	delete $hash->{ $key };

	return ( $key, $value );
}

# ============================================================================

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

sub _attributes_to_hash {

  my $attribute_list = shift;

	my $attributes;
	$attributes -> { $_ -> getName } = $_ -> getValue
    for @$attribute_list;

	return $attributes;

}

# ============================================================================

1;
