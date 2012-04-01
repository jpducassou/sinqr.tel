use strict;
use utf8;
use Sinqrtel::SDB;
use Log::Log4perl;
use Data::Dumper;

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

my $domain_name = 'score';
my $delete_items = {
	fb0000=>[
					 {_dirty=>'1'},
					 {_dirty=>'0'},
					], #delete only said attributes
	fb0000a=>undef,
};

print Dumper( $delete_items );

my $delete_request = {
		DomainName=>$domain_name,
	};

while ( my ($item_name, $attributes) = each %$delete_items ) {
	my $item = { Name => $item_name };
	
	push @{$delete_request->{Item}},$item;
	
	next unless ref $attributes eq 'ARRAY';
	
	foreach my $attribute_pair ( @$attributes ) {
		my @params = %$attribute_pair;
		my $attribute = { Name => $params[0], Value => $params[1] };
		push @{$item->{Attribute}}, $attribute;
	}
}
	#$delete_request = {
	#			DomainName=>'score',
	#			Item=> [
	#							{ Name=>'fb0000a' },
	#							{ Name=>'fb00000323000',
	#							  Attribute=>[
	#														{
	#														Name=>'_dirty',
	#														Value=>0,
	#														}
	#								]
	#							}
	#			],
	#		};

print Dumper( $delete_request );

#$sdb->batchDeleteAttributes( $delete );
#$sdb->batchPutAttributes( $put );
