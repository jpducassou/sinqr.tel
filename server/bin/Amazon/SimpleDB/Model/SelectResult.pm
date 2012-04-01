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


package Amazon::SimpleDB::Model::SelectResult;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::SelectResult
    # 
    # Properties:
    #
    # 
    # Item: Amazon::SimpleDB::Model::Item
    # NextToken: string
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            Item => {FieldValue => [], FieldType => ["Amazon::SimpleDB::Model::Item"]},
            NextToken => { FieldValue => undef, FieldType => "string"},
        };

        bless ($self, $class);
        if (defined $data) {
           $self->_fromHashRef($data); 
        }
        
        return $self;
    }

        sub getItem {
        return shift->{_fields}->{Item}->{FieldValue};
    }

    sub setItem {
        my $self = shift;
        foreach my $item (@_) {
            if (not $self->_isArrayRef($item)) {
                $item =  [$item];    
            }
            $self->{_fields}->{Item}->{FieldValue} = $item;
        }
    }


    sub withItem {
        my ($self, $itemArgs) = @_;
        foreach my $item (@$itemArgs) {
            $self->{_fields}->{Item}->{FieldValue} = $item;
        }
        return $self;
    }   


    sub isSetItem {
        return  scalar (@{shift->{_fields}->{Item}->{FieldValue}}) > 0;
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