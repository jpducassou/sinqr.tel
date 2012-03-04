#!/usr/bin/perl

# ============================================================================
use strict;
use warnings;

# ============================================================================
use Config::Simple;
use Getopt::Long;
use Data::Dumper;

# ============================================================================
use Amazon::SQS::Simple;
use Amazon::SimpleDB::Client;

# ============================================================================
sub _get_queue {

	my ($aws_access_key, $aws_secret_key, $queue_uri) = @_;

	# Create an SQS object
	my $sqs = new Amazon::SQS::Simple( $aws_access_key, $aws_secret_key );

	# Get Existing queue by endpoint
	my $q = $sqs -> GetQueue( $queue_uri );

	return $q;

}

sub _get_message {

	my ($queue, $number_of_messages, $visibility_timeout) = @_;

	# Retrieve a message
	my $msg = $queue -> ReceiveMessage(
		'AttributeName.1'     => 'All' ,
		'MaxNumberOfMessages' => $number_of_messages,
		'VisibilityTimeout'   => $visibility_timeout
	);

	if ( defined $msg ) {

		# my $timestamp;
		# my $body = $msg -> MessageBody();

		print $msg -> MessageBody() . "\n";
		if ( defined $msg -> {Attribute} ) {
			print "\t" . join("|", map {$_->{Name} . '=' . $_->{Value}} @{$msg->{Attribute}} );
		}
		print "\n";

		# Delete the message
		# unless ( $q->DeleteMessage( $msg -> ReceiptHandle() ) ) {
		# 	print "Delete failed\n";
		# }
	} else {
		print "No message visible right now\n";
	}

}

sub _get_attributes {
  my ($sdb, $domain_name, $item_name) = @_;

  my $response = $sdb -> getAttributes({
    DomainName => $domain_name,
    ItemName   => $item_name,
  });

  my $attribute_list = $response->getGetAttributesResult->getAttribute;
  print $_->getName ? ($_->getName, ' - ', $_->getValue, "\n") : ''
    for @$attribute_list;
}


# ============================================================================


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
	# ==========================================================================
	# AWS SQS info
	my $aws_access_key = $config -> {'default.aws_access_key'}; # Your AWS Access Key ID
	my $aws_secret_key = $config -> {'default.aws_secret_key'}; # Your AWS Secret Key
	my $queue_uri      = $config -> {'default.queue_uri'}; # public queue uri

	# Params
	my $visibility_timeout = 1;
	my $number_of_messages = 1;

	my $sdb_domain_name = $config -> {'default.sdb_domain_name'};;

	# ==========================================================================
	# Get tag score chart from S3
	# ==========================================================================

	# ==========================================================================
	# Get message from SQS
	# ==========================================================================
	# get_messages();

	# Get user info from simple db
	my $sdb = new Amazon::SimpleDB::Client( $aws_access_key, $aws_secret_key );
	my $item_name = 'fb0000';

	_get_attributes($sdb, $sdb_domain_name, $item_name);


	# Update score from simpledb

}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
