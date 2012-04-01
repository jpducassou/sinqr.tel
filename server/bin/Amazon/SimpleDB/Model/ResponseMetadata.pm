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


package Amazon::SimpleDB::Model::ResponseMetadata;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::ResponseMetadata
    # 
    # Properties:
    #
    # 
    # RequestId: string
    # BoxUsage: string
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            RequestId => { FieldValue => undef, FieldType => "string"},
            BoxUsage => { FieldValue => undef, FieldType => "string"},
        };

        bless ($self, $class);
        if (defined $data) {
           $self->_fromHashRef($data); 
        }
        
        return $self;
    }

    
    sub getRequestId {
        return shift->{_fields}->{RequestId}->{FieldValue};
    }


    sub setRequestId {
        my ($self, $value) = @_;

        $self->{_fields}->{RequestId}->{FieldValue} = $value;
        return $self;
    }


    sub withRequestId {
        my ($self, $value) = @_;
        $self->setRequestId($value);
        return $self;
    }


    sub isSetRequestId {
        return defined (shift->{_fields}->{RequestId}->{FieldValue});
    }


    sub getBoxUsage {
        return shift->{_fields}->{BoxUsage}->{FieldValue};
    }


    sub setBoxUsage {
        my ($self, $value) = @_;

        $self->{_fields}->{BoxUsage}->{FieldValue} = $value;
        return $self;
    }


    sub withBoxUsage {
        my ($self, $value) = @_;
        $self->setBoxUsage($value);
        return $self;
    }


    sub isSetBoxUsage {
        return defined (shift->{_fields}->{BoxUsage}->{FieldValue});
    }





1;