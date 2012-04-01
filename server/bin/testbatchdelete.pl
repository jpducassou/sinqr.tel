use strict;
use utf8;
use Sinqrtel::SDB;

push @INC,'.';
use Amazon::SimpleDB::Client;

my ( $put ) = {
				DomainName=>'score',
				Item=> [
								{ ItemName=>'fb0000a' ,
									Attribute=>{
																Name=>'score',
																Value=>100,
																Replace=>1,
															}
								},
								{ ItemName=>'fb0000',
									Attribute=>[
															{
																Name=>'score',
																Value=>50,
																Replace=>1,
															},
															{
																Name=>'_dirty',
																Value=>1,
																Replace=>1,
															},
									]
								}
				],
			};

my ( $delete ) = {
				DomainName=>'score',
				Item=> [
								{ Name=>'fb0000a' },
								{ Name=>'fb00000323000',
								  Attribute=>{
															Name=>'_dirty',
															Value=>0,
															}
								}
				],
			};

my $sdb = Amazon::SimpleDB::Client->new( 'AKIAIC2DBRTIUKHMGASQ', '2Ofh3ICjeKpxeWBV2KGmKJ4co4WoeGtpumiiGEPX' );

#$sdb->batchDeleteAttributes( $delete );
eval { $sdb->batchPutAttributes( $put ); };
if ( $@ ) {
	print $@;
	}
