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
	my ( $sdb, $domain_name, $delete_request ) = @_;
	
	my $logger = Log::Log4perl -> get_logger();
	
	#my $delete_items = {
	#	fb0000=>[
	#					{_dirty=>'1'},
	#					{_dirty=>'0'},
	#	], #delete only said attributes
	#	fb0000a=>undef,
	#};
	
	#	convert $delete_items to BatchDeleteRequest format
	#$delete_request = {
	#			DomainName=>'score',
	#			Item=> [
	#							{ Name=>'fb0000a' },
	#							{ Name=>'fb00000323000',
	#							  Attribute=>[
	#														{
	#														Name=>'_dirty',
	#														Value=>0,
	#														}
	#								]
	#							}
	#			],
	#		};
	my $delete_request = {
		DomainName=>$domain_name,
	};

	while ( my ($item_name, $attributes) = each %$delete_items ) {
		my $item = { Name => $item_name };
		push @{$delete_request->{Item}},$item;
		
		next unless ref $attributes eq 'ARRAY';
		
		foreach my $attribute_pair ( @$attributes ) {
			my @params = %$attribute_pair;
			my $attribute = { Name => $params[0], Value => $params[1] };
			#attach some attributes to our item
			push @{$item->{Attribute}}, $attribute;
		}
	}

	eval {
		$sdb->batchDeleteAttributes( $delete_request );
	};
	# Get the exceptions
	my $ex = $@;
	if ($ex) {
		require Amazon::SimpleDB::Exception;
		if (ref $ex eq 'Amazon::SimpleDB::Exception') {
			# Unknown exception type, this is shamefull...
			$logger -> logcarp($@);
		} else {
			#unknown error, we are unworthy of this cpu time
			$logger -> logcarp($@);
		}
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
