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


package Amazon::SimpleDB::Model::UpdateCondition;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::UpdateCondition
    # 
    # Properties:
    #
    # 
    # Name: string
    # Value: string
    # Exists: bool
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            Name => { FieldValue => undef, FieldType => "string"},
            Value => { FieldValue => undef, FieldType => "string"},
            Exists => { FieldValue => undef, FieldType => "bool"},
        };

        bless ($self, $class);
        if (defined $data) {
           $self->_fromHashRef($data); 
        }
        
        return $self;
    }

    
    sub getName {
        return shift->{_fields}->{Name}->{FieldValue};
    }


    sub setName {
        my ($self, $value) = @_;

        $self->{_fields}->{Name}->{FieldValue} = $value;
        return $self;
    }


    sub withName {
        my ($self, $value) = @_;
        $self->setName($value);
        return $self;
    }


    sub isSetName {
        return defined (shift->{_fields}->{Name}->{FieldValue});
    }


    sub getValue {
        return shift->{_fields}->{Value}->{FieldValue};
    }


    sub setValue {
        my ($self, $value) = @_;

        $self->{_fields}->{Value}->{FieldValue} = $value;
        return $self;
    }


    sub withValue {
        my ($self, $value) = @_;
        $self->setValue($value);
        return $self;
    }


    sub isSetValue {
        return defined (shift->{_fields}->{Value}->{FieldValue});
    }


    sub getExists {
        return shift->{_fields}->{Exists}->{FieldValue};
    }


    sub setExists {
        my ($self, $value) = @_;

        $self->{_fields}->{Exists}->{FieldValue} = $value;
        return $self;
    }


    sub withExists {
        my ($self, $value) = @_;
        $self->setExists($value);
        return $self;
    }


    sub isSetExists {
        return defined (shift->{_fields}->{Exists}->{FieldValue});
    }





1;