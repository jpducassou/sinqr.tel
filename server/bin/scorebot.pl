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

# ============================================================================
sub _select {
  my ($sdb, $select_expression, $next_token) = @_;

	my $response = $sdb -> select({
		SelectExpression                        => $select_expression,
		($next_token        ? (NextToken        => $next_token)          : ()),
	});

	return $response -> getSelectResult -> getItem;

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

	my $score_domain_name  = $config -> {'default.score_domain_name'};
	my $sdb_retrieve_limit = $config -> {'default.sdb_retrieve_limit'};

	# ==========================================================================
	# Get Simpledb handler
	# ==========================================================================
	my $sdb = new Amazon::SimpleDB::Client( $aws_access_key, $aws_secret_key );

	# ==========================================================================
	# Get dirty record
	# ==========================================================================
	my $query = "select * from $score_domain_name where _dirty=\"1\" limit sdb_retrieve_limit";
	my $result_list = _select($sdb, $query);

	foreach my $item (@$result_list) {
		warn Dumper($item);

		# Update simpledb as no _dirty


		# Update S3

	}

}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
