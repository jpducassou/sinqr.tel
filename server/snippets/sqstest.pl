use strict;

use Amazon::SQS::Simple;

#AWS Private
my $access_key = 'AKIAIC2DBRTIUKHMGASQ'; # Your AWS Access Key ID
my $secret_key = '2Ofh3ICjeKpxeWBV2KGmKJ4co4WoeGtpumiiGEPX'; # Your AWS Secret Key
my $queue_uri = 'https://queue.amazonaws.com/041722291456/sinqrtel_public'; #public queue uri

#AWS Public
my $public_access_key = 'AKIAJZDRZUXVHSK3G6LA';
my $public_secret_key = 'uBIMu6R7J7Idsdvx18495KlEZ+LEMbUDndOLjUYi';

# Create an SQS object
my $sqs = new Amazon::SQS::Simple( $access_key, $secret_key );

# Get Existing queue by endpoint
my $q = $sqs->GetQueue( $queue_uri );

# Retrieve a message
my $msg = $q->ReceiveMessage( 'AttributeName.1' => 'All' , MaxNumberOfMessages=>1, VisibilityTimeout=>60 );

if ( defined $msg ) {
  print $msg->MessageBody() . "\n";
  if ( defined $msg->{Attribute} ) {
	print "\t" . join("|", map {$_->{Name} . '=' . $_->{Value}} @{$msg->{Attribute}} );
  }

  # Delete the message
#  unless ( $q->DeleteMessage($msg->ReceiptHandle()) ) {
#	print "Delete failed\n";
#  }
} else {
  print "No message visible right now\n";
}
