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


package Amazon::SimpleDB::Model::ReplaceableItem;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::ReplaceableItem
    # 
    # Properties:
    #
    # 
    # ItemName: string
    # Attribute: Amazon::SimpleDB::Model::ReplaceableAttribute
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            ItemName => { FieldValue => undef, FieldType => "string"},
            Attribute => {FieldValue => [], FieldType => ["Amazon::SimpleDB::Model::ReplaceableAttribute"]},
        };

        bless ($self, $class);
        if (defined $data) {
           $self->_fromHashRef($data); 
        }
        
        return $self;
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

    sub getAttribute {
        return shift->{_fields}->{Attribute}->{FieldValue};
    }

    sub setAttribute {
        my $self = shift;
        foreach my $attribute (@_) {
            if (not $self->_isArrayRef($attribute)) {
                $attribute =  [$attribute];    
            }
            $self->{_fields}->{Attribute}->{FieldValue} = $attribute;
        }
    }


    sub withAttribute {
        my ($self, $attributeArgs) = @_;
        foreach my $attribute (@$attributeArgs) {
            $self->{_fields}->{Attribute}->{FieldValue} = $attribute;
        }
        return $self;
    }   


    sub isSetAttribute {
        return  scalar (@{shift->{_fields}->{Attribute}->{FieldValue}}) > 0;
    }





1;