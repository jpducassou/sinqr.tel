#!/usr/bin/perl

# ============================================================================
use strict;
use warnings;

# ============================================================================
use Config::Simple;
use Getopt::Long;
use Data::Dumper;

# ============================================================================
use Amazon::SimpleDB::Client;
use JSON::XS;
use Amazon::S3;
use Error qw(:try);

# ============================================================================
use Sinqrtel::SDB;

# ============================================================================
sub _attributes_to_hash {

  my $attribute_list = shift;

	my $attributes;
	$attributes -> { $_ -> getName } = $_ -> getValue
    for @$attribute_list;

	return $attributes;

}

sub _select {
  my ($sdb, $select_expression, $next_token) = @_;

warn 'query ' . $select_expression;

	my $response;

	eval {
		$response = $sdb -> select({
			SelectExpression                        => $select_expression,
			($next_token        ? (NextToken        => $next_token)          : ()),
		});
		1;
	} or do {
		warn $@ -> getMessage();
		return undef;
	};

	my $item_list = $response -> getSelectResult -> getItem;

	my @result = map { [ $_ -> getName, _attributes_to_hash($_ -> getAttribute)  ]  } @$item_list;
	return \@result;

}


# ============================================================================
sub main {

	# ==========================================================================
	# Get config
	# ==========================================================================
	my $config = {};
	my $config_file = $0; $config_file =~ s/\.([^\.]+)$/\.cfg/;
	die("No config file $config_file!") unless -f $config_file;

	Config::Simple -> import_from($config_file, $config) || die 'cannot find config file.';

	# ==========================================================================
	# AWS SQS info
	# ==========================================================================
	my $aws_access_key = $config -> {'default.aws_access_key'}; # Your AWS Access Key ID
	my $aws_secret_key = $config -> {'default.aws_secret_key'}; # Your AWS Secret Key

	my $sdb_domain_name    = $config -> {'default.sdb_domain_name'};
	my $sdb_retrieve_limit = $config -> {'default.sdb_retrieve_limit'};

	# ==========================================================================
	# Get Simpledb handler
	# ==========================================================================
	my $sdb = new Amazon::SimpleDB::Client( $aws_access_key, $aws_secret_key ) || die 'Cannot create sdb client';

	# ==========================================================================
	# Get dirty record
	# ==========================================================================
	my $query = "select * from $sdb_domain_name where _dirty=\"1\""; # limit sdb_retrieve_limit";
	my $result_list = _select($sdb, $query);

	foreach my $item (@$result_list) {
		warn Dumper($item);

		my $item_name = $item -> [0];
		my $old_timestamp = $item -> [1] -> {'timestamp'} || next; # do not consider items without timestamp

		# Update simpledb as no _dirty
		put_attributes_conditional($sdb, $sdb_domain_name, $item_name, { _dirty => 0 }, $old_timestamp);

		# Update S3

	}

}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
