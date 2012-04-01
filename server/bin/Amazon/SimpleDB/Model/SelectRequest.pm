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


package Amazon::SimpleDB::Model::SelectRequest;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::SelectRequest
    # 
    # Properties:
    #
    # 
    # SelectExpression: string
    # NextToken: string
    # ConsistentRead: bool
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            SelectExpression => { FieldValue => undef, FieldType => "string"},
            NextToken => { FieldValue => undef, FieldType => "string"},
            ConsistentRead => { FieldValue => undef, FieldType => "bool"},
        };

        bless ($self, $class);
        if (defined $data) {
           $self->_fromHashRef($data); 
        }
        
        return $self;
    }

    
    sub getSelectExpression {
        return shift->{_fields}->{SelectExpression}->{FieldValue};
    }


    sub setSelectExpression {
        my ($self, $value) = @_;

        $self->{_fields}->{SelectExpression}->{FieldValue} = $value;
        return $self;
    }


    sub withSelectExpression {
        my ($self, $value) = @_;
        $self->setSelectExpression($value);
        return $self;
    }


    sub isSetSelectExpression {
        return defined (shift->{_fields}->{SelectExpression}->{FieldValue});
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