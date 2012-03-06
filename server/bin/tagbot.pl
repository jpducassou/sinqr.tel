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

		return $msg;

		# Delete the message
		# unless ( $q->DeleteMessage( $msg -> ReceiptHandle() ) ) {
		# 	print "Delete failed\n";
		# }
	} else {
		print "No message visible right now\n";
		return undef;
	}

}

sub _dump_msg {
	my $msg = shift;

	print $msg -> MessageBody() . "\n";
	if ( defined $msg -> {Attribute} ) {
		print "\t" . join('|', map {$_ -> {Name} . '=' . $_ -> {Value}} @{$msg -> {Attribute}} );
	}
	print "\n";

}

sub _get_attributes {
  my ($sdb, $domain_name, $item_name) = @_;

  my $response = $sdb -> getAttributes({
    DomainName => $domain_name,
    ItemName   => $item_name,
  });

  my $attribute_list = $response -> getGetAttributesResult -> getAttribute;

	# return _list_to_hash($attribute_list);
	my $attributes;
	$attributes -> { $_ -> getName } = $_ -> getValue
		for @$attribute_list;

	return $attributes;

}

sub _put_attributes {
  my ($sdb, $domain_name, $item_name, $attributes, $expected) = @_;

	$attributes = _hash_to_list($attributes, 'Replace', 1);
warn Dumper($attributes);

  my $response = $sdb -> putAttributes({
    DomainName => $domain_name,
    ItemName   => $item_name,
    Attribute  => $attributes,
		Expected   => { 'Name' => 'timestamp', 'Value' => $expected, 'Exists' => 'true' },
  });
}

sub _hash_to_list {
  my ($values, $condition_name, $condition_value) = @_;

  my @attributes = ();

  for my $name ( keys %$values ) {
    my $value = $values -> { $name };

    push @attributes, {
      Name  => $name,
      Value => $value,
      ($condition_value ? ($condition_name => $condition_value ? 'true' : '') : ()),
    };
  }
  return \@attributes;
}

sub _list_to_hash {
	my $attribute_list = shift;

	my $attributes;
	$attributes -> { $_ -> {'Name'} } = $_ -> {'Value'}
    for @$attribute_list;

	return $attributes;

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

	# ==========================================================================
	# AWS SQS info
	my $aws_access_key = $config -> {'default.aws_access_key'}; # Your AWS Access Key ID
	my $aws_secret_key = $config -> {'default.aws_secret_key'}; # Your AWS Secret Key
	my $queue_uri      = $config -> {'default.queue_uri'}; # public queue uri

	# Params
	my $visibility_timeout = 1;
	my $number_of_messages = 1;

	my $sdb_domain_name = $config -> {'default.sdb_domain_name'};;

	my $tag_value = $config -> {'default.tag_value'};;

	# ==========================================================================
	# Get SQS queue
	# ==========================================================================
	my $queue = _get_queue($aws_access_key, $aws_secret_key, $queue_uri) || die 'Cannot get SQS queue';

	# ==========================================================================
	# Get simpledb handler
	# ==========================================================================
	my $sdb = new Amazon::SimpleDB::Client( $aws_access_key, $aws_secret_key );

	# ==========================================================================
	# Get message from SQS
	# ==========================================================================
	my $msg = _get_message($queue, $number_of_messages, $visibility_timeout);

	my $sqs_attributes = _list_to_hash($msg -> {Attribute});
	my $timestamp = $sqs_attributes -> {'SentTimestamp'};
	my $body = $msg -> MessageBody();

	# _dump_msg($msg);
	if ( $body =~ /v1\|((fb|tw)(\w+))\|((fb|tw|wp)(\w+))/ ) {
		my $origin = $1;
		my $destin = $4;
		warn "TAG from:$origin to:$destin";

		# Get user info from simple db
		my $sdb_attributes = _get_attributes($sdb, $sdb_domain_name, $origin);
		warn 'SDB:'.Dumper($sdb_attributes);

		my $new_attributes = {
			'score'     => $sdb_attributes -> {'score'} + $tag_value,
			'timestamp' => $timestamp,
		};

		# Update score from simpledb
		_put_attributes($sdb, $sdb_domain_name, $origin, $new_attributes, $sdb_attributes -> {'timestamp'});

	} else {
		warn "SQS message format unrecognized.";
	}

}

# ============================================================================
main( @ARGV ) unless caller();

# ============================================================================
# return true
1;
