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

sub _get_messages {
	my ($queue, $number_of_messages, $visibility_timeout) = @_;
	#my @messages;
	
	# Retrieve messages
	my @messages = $queue -> ReceiveMessage(
		'AttributeName.1'     => 'SentTimestamp' ,
		'MaxNumberOfMessages' => $number_of_messages,
		'VisibilityTimeout'   => $visibility_timeout
	);

	if ( @messages ) {
		# check final array format
		foreach my $message ( @messages ) {
			# die on unknown message formats
			die("SQS unexpected message format") unless
				defined $message -> MessageBody() &&
				defined $message -> {Attribute} -> {Name} &&
				$message -> {Attribute} -> {Name} eq 'SentTimestamp' &&
				$message -> {Attribute} -> {Value} =~ /^\d+$/
		}
	}
	
	return \@messages;
}

sub _get_score {
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

sub _put_attributes_conditional {
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

sub _message_to_tag_hash {
	my ( $message, $config ) = @_;
	
	my $tag;
	my ( $message_version, $message_format_v1);
	
	#*move to config file
	if ( $message -> MessageBody() =~ /^v(\d+)/ ) {
		my ( $version, $from, $to ) = ( $1, undef, undef );
		if ( $version == 1 ) {
			#*move to config file
			$message -> MessageBody() =~ /^(v1)\|([^\|]*)\|([^\|]*)$/;
			$tag->{from} = $2; $tag->{to} = $3; $tag->{timestamp} = $message -> {Attribute} -> {Value};
			$tag->{tag_value} = $config -> {'default.tag_value'};
		} else {
			die("Unsupported message version for ReceiptHandle" . $message->ReceiptHandle());
		}
	} else {
		die("Message format unspected, no version info")
	}
	
	return $tag;
}


# ============================================================================
# MAIN
# ============================================================================

sub main {

	# ==========================================================================
	# Get config
	# ==========================================================================
	my $config = {};
	my $config_file = $0; $config_file =~ s/\.([^\.]+)$/\.cfg/;
	die("No config file $config_file!") unless -f $config_file;

	Config::Simple -> import_from($config_file, $config) || die 'cannot find config file.';
	
	die("No queue_uri in config file") unless defined $config -> {'default.queue_uri'} && $config -> {'default.queue_uri'} =~ /queue\.amazonaws\.com/;
	die("No score_domain_name in config file") unless defined $config -> {'default.score_domain_name'} &&  $config -> {'default.score_domain_name'} =~ /\w+/;
	die("No tag_value in config file") unless defined $config -> {'default.tag_value'} && $config -> {'default.tag_value'} > 0;
	die("No single_message_timeout in config file") unless defined $config -> {'default.single_message_timeout'} && $config -> {'default.single_message_timeout'} > 0;

	# ==========================================================================
	# ==========================================================================
	# AWS SQS info
	my $aws_access_key = $config -> {'default.aws_access_key'}; # Your AWS Access Key ID
	my $aws_secret_key = $config -> {'default.aws_secret_key'}; # Your AWS Secret Key
	my $queue_uri      = $config -> {'default.queue_uri'}; # public queue uri

	# =====
	#*These should go to GetOpt::Long and default config
	# =====
	my $message_number = $config -> {'default.message_number'} || 1; #how much messages to get on a single request
	#*$config -> {'default.single_message_timeout'} should be configurable, change required from config file

	# Define visibility timeout according to number of messages + a maximum of one extra message timeout
	my $visibility_timeout = $message_number * $config -> {'default.single_message_timeout'} + int(rand($config -> {'default.single_message_timeout'}));
	my $score_domain_name  = $config -> {'default.score_domain_name'};

	# ==========================================================================
	# Get tag score chart from S3
	# ==========================================================================

	# ==========================================================================
	# Get SQS queue
	# ==========================================================================
	my $queue = _get_queue( $aws_access_key, $aws_secret_key, $queue_uri );
	
	# ==========================================================================
	# Get Simpledb handler
	# ==========================================================================
	my $sdb = new Amazon::SimpleDB::Client( $aws_access_key, $aws_secret_key );

	# ==========================================================================
	# Get message from SQS
	# ==========================================================================
	my $messages = _get_messages( $queue, $message_number, $visibility_timeout );

	if ( defined $messages && ref $messages eq 'ARRAY' && @$messages ) {

		# process received messages
		foreach my $message ( @$messages ) {
			my $tag = _message_to_tag_hash( $message, $config );
			my $item_name = $tag->{from};

warn 'item_name: ' . $item_name;
			
			my $stored_correctly_on_sdb = 0;
			do {
				my $score = _get_score( $sdb, $score_domain_name, $item_name );
				#keep old time stamp for conditional put
				my $old_timestamp = $score -> {timestamp};
		
				warn Dumper( $score );
				
				#update attributes inplace so as not to kill attributes that do not get updates!
					
				# add tag value to score
				$score -> {score} += $tag -> {tag_value};
				# update timestamp
				$score -> {timestamp} = $tag -> {timestamp};
				# Update score to simpledb
				$stored_correctly_on_sdb = _put_attributes_conditional($sdb, $score_domain_name, $item_name, $score, $old_timestamp);
				print "Retrying on $item_name do to timestamp skew\n" unless $stored_correctly_on_sdb;
			} until ( $stored_correctly_on_sdb );
		}
	}
}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
