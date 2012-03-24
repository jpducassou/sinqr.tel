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
@EXPORT = qw(get_attributes put_attributes_conditional select_attributes);


# ============================================================================
sub get_attributes {
  my ($sdb, $domain_name, $item_name) = @_;
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
	#get exceptions
	my $ex = $@;
	if ($ex) {
		require Amazon::SimpleDB::Exception;
		if (ref $ex eq "Amazon::SimpleDB::Exception") {
			croack $@;
		} else {
			croack $@;
		}
	}

	return $attributes;
}

sub put_attributes {
  my ($sdb, $domain_name, $item_name, $attributes, $expected) = @_;

	my $request_attributes = _hash_to_attributes($attributes, 'Replace', 1);

	my $request = {
		DomainName => $domain_name,
		ItemName   => $item_name,
		Attribute  => $request_attributes,
	};

	#only expect timestamp for values $item_names that exist (and have a timestamp > 0)
	if ( defined $expected ) {
		$request->{Expected} = $expected;
	}

	warn Dumper( $request );

	my $response = 1;
	my $condition_failed = 0;
	eval {
		$sdb -> putAttributes( $request );
	};
	#get exceptions
	my $ex = $@;
	if ($ex) {
		require Amazon::SimpleDB::Exception;
		if (ref $ex eq "Amazon::SimpleDB::Exception") {
			if ($ex->{_errorCode} eq 'ConditionalCheckFailed') {
				#just in case we check for more states in the future
				$response = 0;
				$condition_failed = 1;
			} else {
				#unknown error, we are unworthy of this cpu time
				croack $@;
			}
		} else {
			#unknown exception type, this is really bad...
			croack $@;
		}
	}

	return ( $response, $condition_failed );
}

sub select_attributes {
  my ($sdb, $select_expression, $next_token) = @_;

	my $response;

	eval {
		$response = $sdb -> select({
			SelectExpression                        => $select_expression,
			($next_token        ? (NextToken        => $next_token)          : ()),
		});
		1;
	} or do {
		die $@ -> getMessage();
	};

	my $item_list = $response -> getSelectResult -> getItem;

	my @result = map { [ $_ -> getName, _attributes_to_hash($_ -> getAttribute)  ]  } @$item_list;
	return \@result;

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
