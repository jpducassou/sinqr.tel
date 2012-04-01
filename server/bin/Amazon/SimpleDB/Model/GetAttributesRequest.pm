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


package Amazon::SimpleDB::Model::GetAttributesRequest;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::GetAttributesRequest
    # 
    # Properties:
    #
    # 
    # DomainName: string
    # ItemName: string
    # AttributeName: string
    # ConsistentRead: bool
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            DomainName => { FieldValue => undef, FieldType => "string"},
            ItemName => { FieldValue => undef, FieldType => "string"},
            AttributeName => {FieldValue => [], FieldType => ["string"]},
            ConsistentRead => { FieldValue => undef, FieldType => "bool"},
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


    sub setDomainName {
        my ($self, $value) = @_;

        $self->{_fields}->{DomainName}->{FieldValue} = $value;
        return $self;
    }


    sub withDomainName {
        my ($self, $value) = @_;
        $self->setDomainName($value);
        return $self;
    }


    sub isSetDomainName {
        return defined (shift->{_fields}->{DomainName}->{FieldValue});
    }


    sub getItemName {
        return shift->{_fields}->{ItemName}->{FieldValue};
    }


    sub setItemName {
        my ($self, $value) = @_;

        $self->{_fields}->{ItemName}->{FieldValue} = $value;
        return $self;
    }


    sub withItemName {
        my ($self, $value) = @_;
        $self->setItemName($value);
        return $self;
    }


    sub isSetItemName {
        return defined (shift->{_fields}->{ItemName}->{FieldValue});
    }

    sub getAttributeName {
        return shift->{_fields}->{AttributeName}->{FieldValue};
    }


    sub setAttributeName    {
        my ($self, $value) = @_;
        $self->{_fields}->{AttributeName}->{FieldValue} = $value;
        return $self;
    }



    sub withAttributeName {
        my $self = shift;
            my $list = $self->{_fields}->{AttributeName}->{FieldValue};
            for (@_) {
                push (@$list, $_);
            }
        return $self;
    }  
      

    sub isSetAttributeName {
        return scalar (@{shift->{_fields}->{AttributeName}->{FieldValue}}) > 0;
    }


    sub getConsistentRead {
        return shift->{_fields}->{ConsistentRead}->{FieldValue};
    }


    sub setConsistentRead {
        my ($self, $value) = @_;

        $self->{_fields}->{ConsistentRead}->{FieldValue} = $value;
        return $self;
    }


    sub withConsistentRead {
        my ($self, $value) = @_;
        $self->setConsistentRead($value);
        return $self;
    }


    sub isSetConsistentRead {
        return defined (shift->{_fields}->{ConsistentRead}->{FieldValue});
    }





1;