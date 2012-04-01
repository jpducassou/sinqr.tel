use strict;
use utf8;
use Sinqrtel::SDB;

push @INC,'.';
use Amazon::SimpleDB::Client;

my ( $delete ) = {
				DomainName=>'score',
				Item=> [
								{ Name=>'fb0000a' },
								{ Name=>'fb0000',
								  Attribute=>{
															Name=>'_dirty',
															Value=>1,
															}
								}
				],
			};

my $sdb = Amazon::SimpleDB::Client->new( 'AKIAIC2DBRTIUKHMGASQ', '2Ofh3ICjeKpxeWBV2KGmKJ4co4WoeGtpumiiGEPX' );

$sdb->batchDeleteAttributes( $delete );