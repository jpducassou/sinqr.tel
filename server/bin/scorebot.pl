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
		die $@ -> getMessage();
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
	my $aws_access_key = $config -> {'aws_access_key'}; # Your AWS Access Key ID
	my $aws_secret_key = $config -> {'aws_secret_key'}; # Your AWS Secret Key

	my $sdb_domain_name    = $config -> {'sdb_domain_name'};
	my $sdb_retrieve_limit = $config -> {'sdb_retrieve_limit'};

	# ==========================================================================
	# Get Simpledb handler
	# ==========================================================================
	my $sdb = new Amazon::SimpleDB::Client( $aws_access_key, $aws_secret_key ) || die 'Cannot create sdb client';

	# ==========================================================================
	# Set up Amazon
	# ==========================================================================
	my $s3 = Amazon::S3 -> new({
		aws_access_key_id     => $config -> {'aws_access_key'},
		aws_secret_access_key => $config -> {'aws_secret_key'},
		secure                => $config -> {'secure'},
	});

	# ==========================================================================
	# Select bucket
	# ==========================================================================
	my $bucket = $s3 -> bucket( $config -> {'score_online_bucket'} );
	my $score_online_base_uri = $config -> {'score_online_base_uri'};

	# ==========================================================================
	# Get dirty record
	# ==========================================================================
	my $query = "select * from $sdb_domain_name where _dirty=\"1\""; # limit sdb_retrieve_limit";
	my $result_list = _select($sdb, $query);

	foreach my $item (@$result_list) {
		warn Dumper($item);

		my $item_name = $item -> [0];
		my $item_hash = $item -> [1];
		my $old_timestamp = $item_hash -> {'timestamp'} || next; # do not consider items without timestamp

		# Update simpledb as no _dirty - if it fails, it means someone is updating
		# put_attributes_conditional($sdb, $sdb_domain_name, $item_name, { _dirty => 0 }, $old_timestamp) || next;

		# Clean "hidden" fields
		foreach my $key (keys %$item_hash) {
			delete $item_hash -> {$key} if ($key =~ /^_/);
		}
		warn Dumper($item_hash);

		# Update S3
		my $utf8_encoded_json_text = encode_json($item_hash);

		warn 'Subiendo a: ' .
			$config -> {'score_online_bucket'} . '.' .
			$s3 -> host . '/' .
			$score_online_base_uri . $item_name . '.json';

		if ( $bucket -> add_key(
			$score_online_base_uri . $item_name . '.json',
			$utf8_encoded_json_text , {
				content_type        => 'application/json',
				acl_short           => $config -> {'score_acl'},
			})
		) {
			print "Uploaded with no errors\n";
		} else {
			print "ERROR UPLOADING!!!\n";
		}

	}

}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
