#!/usr/bin/perl

# ============================================================================
use strict;
use warnings;
use Carp;

# ============================================================================
use Config::Simple;
use Getopt::Long;
use Log::Log4perl qw/:easy/;
use Data::Dumper;

# ============================================================================
use Amazon::SQS::Simple;
use Amazon::SimpleDB::Client;

# ============================================================================
use Sinqrtel::SDB;

# ============================================================================
# Smooth termination
my $mustend = 0;

sub _catch_sig {
	my $signame = shift;
	
	if ( $signame eq 'INT' || $signame eq 'TERM' ) {
		$mustend = 1;
	}
}

# ==============================================================================

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
			$tag->{tag_value} = $config -> {'tag_value'};
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
	$logger -> info('Starting tagbot.');

	# ==========================================================================
	# Get config
	# ==========================================================================
	my $config = {};
	my $config_file = $0; $config_file =~ s/\.([^\.]+)$/\.cfg/;
	$logger -> logdie("No config file $config_file!") unless -f $config_file;
	$logger -> logdie('cannot find config file.') unless Config::Simple -> import_from($config_file, $config);
	
	$logger -> logwarn("THIS IS A NO DELETE RUN, no messages are deleted, SCORES ARE COMPUTED!") if ( $config -> {'no_delete_run'} );

	$logger -> logdie('No queue_uri in config file') unless defined $config -> {'queue_uri'} && $config -> {'queue_uri'} =~ /queue\.amazonaws\.com/;
	$logger -> logdie('No score_domain_name in config file') unless defined $config -> {'score_domain_name'} &&  $config -> {'score_domain_name'} =~ /\w+/;
	$logger -> logdie('No tag_value in config file') unless defined $config -> {'tag_value'} && $config -> {'tag_value'} > 0;
	$logger -> logdie('No single_message_timeout in config file') unless defined $config -> {'single_message_timeout'} && $config -> {'single_message_timeout'} > 0;

	# ==========================================================================
	# AWS SQS info
	# ==========================================================================
	my $aws_access_key = $config -> {'aws_access_key'}; # Your AWS Access Key ID
	my $aws_secret_key = $config -> {'aws_secret_key'}; # Your AWS Secret Key
	my $queue_uri      = $config -> {'queue_uri'};      # public queue uri

	# =====
	#*These should go to GetOpt::Long and default config
	# =====
	my $message_number = $config -> {'message_number'} || 1; # how many messages to get on a single request
	
	# ==========================================================================
	# Get SimpleDB handler
	# ==========================================================================
	my $sdb = new Amazon::SimpleDB::Client( $aws_access_key, $aws_secret_key );

	# ==========================================================================
	# Get message from SQS
	# ==========================================================================
	# Define visibility timeout according to number of messages + a maximum of one extra message timeout
	my $visibility_timeout = $message_number * $config -> {'single_message_timeout'} + int(rand($config -> {'single_message_timeout'}));
	my $score_domain_name  = $config -> {'score_domain_name'};
	my $interactions_domain_name = $config -> {'interactions_domain_name'};
	my $interactions_cooldown = $config -> {'interactions_cool_down'};

	my $queue = _get_queue( $aws_access_key, $aws_secret_key, $queue_uri ) || $logger -> logdie('Error getting queue');

	# ==========================================================================
	# Do until signal is caught
	# ==========================================================================
	while(!$mustend) {
		my $messages = _get_messages( $queue, $message_number, $visibility_timeout );

		# Process messages if we have a non empty array
		if ( defined $messages && @$messages ) {

			# Process received messages
			foreach my $message ( @$messages ) {

				# Log timestamp and body for replay
				$logger -> info( 'timestamp:[' . $message -> {Attribute} -> {Value} . ']:' . $message -> MessageBody());

				my $tag = _message_to_tag_hash( $message, $config );
				my $item_name = $tag -> {from};
				my $interaction_item_name = $tag -> {from} . '|' . $tag -> {to};

				my $stored_correctly_on_sdb = 0;
				
				my $last_interaction = get_attributes( $sdb, $interactions_domain_name, $interaction_item_name );
				
				if ( defined $last_interaction -> {timestamp} && $tag -> {timestamp} <= $last_interaction -> {timestamp} + $config -> {interactions_cool_down} ) {
					do {
						my $score = get_attributes( $sdb, $score_domain_name, $item_name );
						# keep old time stamp for conditional put (could be undef and must be checked)
	
						$logger -> debug(Dumper( $score ));
	
						# Initialize for non existent users, avoid warnings
						$score -> {score} = 0 unless defined $score -> {score};
						$score -> {timestamp} = 0 unless defined $score -> {timestamp};
	
						# Create attributes to replace
						my $new_score = {
							# add tag value to score
							'score'	=> $score -> {score} + $tag -> {tag_value},
							# add tag value to score
							'timestamp'	=> $tag -> {timestamp},
							# mark as dirty
							_dirty => 1,
						};
	
						# Update score to simpledb
						$stored_correctly_on_sdb = put_attributes($sdb, $score_domain_name, $item_name, $new_score,
																				#expect timestamp not to change from last check
																				{
																				 'Name' => 'timestamp',
																				 'Value' => $score -> {timestamp},
																				 'Exists' => 'true'
																			 });
	
						if ( $stored_correctly_on_sdb ) {
							# set $config -> {'no_delete_run'} to false to have messages deleted
							_delete_message( $queue, $message ) unless ( $config -> {'no_delete_run'} );
							$logger -> info('Message stored in db and deleted from queue');
						} else {
							$logger -> logwarn("Retrying on $item_name do to timestamp skew");
						}
					} until ( $stored_correctly_on_sdb );
					#set las interaction time
					put_attributes($sdb, $interactions_domain_name, $interaction_item_name, {timestamp=>$tag->{timestamp}});
				} else {
					$logger -> logwarn("Dismissed tag within cooldown period for $item_name");
				}
			}
		} else {
			# sleep for a couple of secs when we get out of messages
			sleep $config -> {'sleep_no_messages'}
		}
	}

	$logger -> info('Ending tagbot.');
}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
