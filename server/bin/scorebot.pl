#!/usr/bin/perl

# ============================================================================
use strict;
use warnings;

# ============================================================================
use Config::Simple;
use Getopt::Long;
use Log::Log4perl qw/:easy/;
use Data::Dumper;

# ============================================================================
use Amazon::SimpleDB::Client;
use JSON::XS;
use Amazon::S3;

# ============================================================================
use Sinqrtel::SDB;

# ============================================================================
# Smooth termination
# ============================================================================
my $mustend = 0;

sub _catch_sig {
	my $signame = shift;

	if ( $signame eq 'INT' || $signame eq 'TERM' ) {
		$mustend = 1;
	}
}

# ============================================================================
# MAIN
# ============================================================================
sub main {

	# ==========================================================================
	# Register handler for the SIGINT & SIGTERM signal:
	# ==========================================================================
	$SIG{INT}  = \&_catch_sig;
	$SIG{TERM} = \&_catch_sig;

	# ==========================================================================
	# Get logger
	# ==========================================================================
	Log::Log4perl -> easy_init({
		level => $INFO,
		layout => '[%d] [%p] %F, line %L: %m%n',
	});
	my $logger = Log::Log4perl -> get_logger();
	$logger -> info('Starting scorebot.');

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
	# Query for dirty records
	# ==========================================================================
	my $query = "select * from $sdb_domain_name where _dirty=\"1\""; # limit sdb_retrieve_limit";
	$logger -> debug('Using: ' . $query);

	# ==========================================================================
	# Get dirty record
	# ==========================================================================
	while(!$mustend) {
		my $result_list = select_attributes($sdb, $query);

		foreach my $item (@$result_list) {
			# warn Dumper($item);

			my $item_name = $item -> [0];
			my $item_hash = $item -> [1];
			my $old_timestamp = $item_hash -> {'timestamp'} || next; # do not consider items without timestamp

			# Update simpledb as no _dirty - if it fails, it means someone is updating
			# put_attributes_conditional($sdb, $sdb_domain_name, $item_name, { _dirty => 0 }, $old_timestamp) || next;

			# Clean "hidden" fields
			foreach my $key (keys %$item_hash) {
				delete $item_hash -> {$key} if ($key =~ /^_/);
			}

			# Update S3
			my $utf8_encoded_json_text = encode_json($item_hash);

			my $uri = $score_online_base_uri . $item_name . '.json';

			# full path would be $config -> {'score_online_bucket'} . '.' . $s3 -> host . '/' .	$uri
			$logger -> info("Uploading '$uri'");

			if ( $bucket -> add_key(
				$uri,
				$utf8_encoded_json_text , {
					content_type        => 'application/json',
					acl_short           => $config -> {'score_acl'},
				})
			) {
				$logger -> info("Uploaded '$uri' with no errors");
			} else {
				$logger -> error("Error uploading '$uri'");
			}

		}

		# sleep for a couple of secs when we get out of messages
		sleep($config -> {'sleep_no_messages'} || 10);

	}

	$logger -> info('Ending scorebot.');

}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
