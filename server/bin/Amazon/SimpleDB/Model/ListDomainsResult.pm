################################################################################ 
#  Copyright 2008-2009 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#  Licensed under the Apache License, Version 2.0 (the "License"); 
#  
#  You may not use this file except in compliance with the License. 
#  You may obtain a copy of the License at: http://aws.amazon.com/apache2.0
#  This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
#  CONDITIONS OF ANY KIND, either express or implied. See the License for the 
#  specific language governing permissions and limitations under the License.
################################################################################ 
#    __  _    _  ___ 
#   (  )( \/\/ )/ __)
#   /__\ \    / \__ \
#  (_)(_) \/\/  (___/
# 
#  Amazon Simple DB Perl Library
#  API Version: 2009-04-15
#  Generated: Wed Jan 06 15:57:43 PST 2010 
# 


package Amazon::SimpleDB::Model::ListDomainsResult;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::ListDomainsResult
    # 
    # Properties:
    #
    # 
    # DomainName: string
    # NextToken: string
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            DomainName => {FieldValue => [], FieldType => ["string"]},
            NextToken => { FieldValue => undef, FieldType => "string"},
        };

        bless ($self, $class);
        if (defined $data) {
           $self->_fromHashRef($data); 
        }
        
        return $self;
    }

        sub getDomainName {
        return shift->{_fields}->{DomainName}->{FieldValue};
    }


    sub setDomainName    {
        my ($self, $value) = @_;
        $self->{_fields}->{DomainName}->{FieldValue} = $value;
        return $self;
    }



    sub withDomainName {
        my $self = shift;
            my $list = $self->{_fields}->{DomainName}->{FieldValue};
            for (@_) {
                push (@$list, $_);
            }
        return $self;
    }  
      

    sub isSetDomainName {
        return scalar (@{shift->{_fields}->{DomainName}->{FieldValue}}) > 0;
    }


    sub getNextToken {
        return shift->{_fields}->{NextToken}->{FieldValue};
    }


    sub setNextToken {
        my ($self, $value) = @_;

        $self->{_fields}->{NextToken}->{FieldValue} = $value;
        return $self;
    }


    sub withNextToken {
        my ($self, $value) = @_;
        $self->setNextToken($value);
        return $self;
    }


    sub isSetNextToken {
        return defined (shift->{_fields}->{NextToken}->{FieldValue});
    }





1;