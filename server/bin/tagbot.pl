#!/usr/bin/perl

# ============================================================================
use strict;
use warnings;

# ============================================================================
use Amazon::SQS::Simple;
use Config::Simple;
use Getopt::Long;
use Data::Dumper;

# ============================================================================
sub get_messages {

	my $config = {};
	my $config_file = $0; $config_file =~ s/\.([^\.]+)$/\.cfg/;
	die("No config file $config_file!") unless -f $config_file;

	Config::Simple -> import_from($config_file, $config) || die 'cannot find config file.';

	# AWS SQS info
	my $sqs_access_key = $config -> {'default.sqs_access_key'}; # Your AWS Access Key ID
	my $sqs_secret_key = $config -> {'default.sqs_secret_key'}; # Your AWS Secret Key
	my $queue_uri      = $config -> {'default.queue_uri'}; # public queue uri

	# Params
	my $visibility_timeout = 1;
	my $number_of_messages = 1;

	# Create an SQS object
	my $sqs = new Amazon::SQS::Simple( $sqs_access_key, $sqs_secret_key );

	# Get Existing queue by endpoint
	my $q = $sqs -> GetQueue( $queue_uri );

	# Retrieve a message
	my $msg = $q -> ReceiveMessage(
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

# ============================================================================

sub main {

	print "tagbot.\n";
	# Get config

	# Get tag score chart from S3

	# Get message from SQS
	get_messages();

	# Get user info from simple db
	# Update score from simpledb

}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
