#!/usr/bin/perl

# ============================================================================
use strict;
use warnings;
use Carp;

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

	# Get existing queue by endpoint
	my $q = $sqs -> GetQueue( $queue_uri );

	return $q;
}

sub _get_messages {
	my ($queue, $number_of_messages, $visibility_timeout) = @_;
	
	# Retrieve messages
	my @messages = $queue -> ReceiveMessage(
		'AttributeName.1'     => 'SentTimestamp' ,
		'MaxNumberOfMessages' => $number_of_messages,
		'VisibilityTimeout'   => $visibility_timeout
	);

	if ( @messages ) {
		# check final array format for XML::Simple convertion problems...
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

sub _delete_message {
	my ( $queue, $message ) = @_;
	
	$queue -> DeleteMessage( $message -> ReceiptHandle() );
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

	my $request_attributes = _hash_to_attributes($attributes, 'Replace', 1);
	
	my $request = {
		DomainName => $domain_name,
		ItemName   => $item_name,
		Attribute  => $request_attributes,
	};
	
	#only expect timestamp for values $item_names that exist (and have a timestamp > 0)
	if ( $expected_timestamp > 0) {
		$request->{Expected} = { 'Name' => 'timestamp', 'Value' => $expected_timestamp, 'Exists' => 'true'};
	}
	
	warn Dumper( $request );
	
	my $response = 1;
	eval {
		$sdb -> putAttributes( $request );
	};
	#get exceptions
	my $ex = $@;
	if ($ex) {
		require Amazon::SimpleDB::Exception;
		if (ref $ex eq "Amazon::SimpleDB::Exception") {
			if ($ex->{_errorCode} eq 'ConditionalCheckFailed') {
				$response = 0;
			} else {
				#unknown error, we are unworthy of this cpu time
				croack $@;
			}
		} else {
			#unknown exception type, this is really bad...
			croack $@;
		}
	}
	
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
	if ( $message -> MessageBody() =~ /^v(\d+)\|/ ) {
		my ( $version, $from, $to ) = ( $1, undef, undef );
		if ( $version == 1 ) {
			#*move to config file
			$message -> MessageBody() =~ /^(v1)\|((?:fb|tw)(?:\w+))\|((?:fb|tw|wp)(?:\w+))$/;
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

	# ==========================================================================
	# Get tag score chart from S3
	# ==========================================================================

	# ==========================================================================
	# Get message from SQS
	# ==========================================================================
	
	# Define visibility timeout according to number of messages + a maximum of one extra message timeout
	my $visibility_timeout = $message_number * $config -> {'default.single_message_timeout'} + int(rand($config -> {'default.single_message_timeout'}));
	my $score_domain_name  = $config -> {'default.score_domain_name'};

	my $queue = _get_queue( $aws_access_key, $aws_secret_key, $queue_uri );
	
	my $messages = _get_messages( $queue, $message_number, $visibility_timeout );

	#process messages if we have a non empty array
	if ( defined $messages && @$messages ) {
		my $sdb = new Amazon::SimpleDB::Client( $aws_access_key, $aws_secret_key );
		
		#process received messages
		foreach my $message ( @$messages ) {
			my $tag = _message_to_tag_hash( $message, $config );
			my $item_name = $tag->{from};
			
			my $stored_correctly_on_sdb = 0;
			do {
				my $score = _get_score( $sdb, $score_domain_name, $item_name );
				#keep old time stamp for conditional put (could be undef and must be checked)
			
				warn Dumper( $score );
				
				#initialize for non existent users, avoid warnings
				$score -> {score} = 0 unless defined $score -> {score};
				$score -> {timestamp} = 0 unless defined $score -> {timestamp};
				
				#cerate attributes to replace
				my $new_score = {
					#add tag value to score					
					'score'	=> $score -> {score} + $tag -> {tag_value},
					#add tag value to score
					'timestamp'	=> $tag -> {timestamp},
				};
				# Update score to simpledb
				$stored_correctly_on_sdb = _put_attributes_conditional($sdb, $score_domain_name, $item_name, $new_score, $score->{timestamp});
				if ( $stored_correctly_on_sdb ) {
					_delete_message( $queue, $message );
					print "Ready!\n";
				} else {
					warn "Retrying on $item_name do to timestamp skew";
				}
			} until ( $stored_correctly_on_sdb );
		}
	}
}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
