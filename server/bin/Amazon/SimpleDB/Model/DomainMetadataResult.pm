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


package Amazon::SimpleDB::Model::DomainMetadataResult;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::DomainMetadataResult
    # 
    # Properties:
    #
    # 
    # ItemCount: string
    # ItemNamesSizeBytes: string
    # AttributeNameCount: string
    # AttributeNamesSizeBytes: string
    # AttributeValueCount: string
    # AttributeValuesSizeBytes: string
    # Timestamp: string
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            ItemCount => { FieldValue => undef, FieldType => "string"},
            ItemNamesSizeBytes => { FieldValue => undef, FieldType => "string"},
            AttributeNameCount => { FieldValue => undef, FieldType => "string"},
            AttributeNamesSizeBytes => { FieldValue => undef, FieldType => "string"},
            AttributeValueCount => { FieldValue => undef, FieldType => "string"},
            AttributeValuesSizeBytes => { FieldValue => undef, FieldType => "string"},
            Timestamp => { FieldValue => undef, FieldType => "string"},
        };

        bless ($self, $class);
        if (defined $data) {
           $self->_fromHashRef($data); 
        }
        
        return $self;
    }

    
    sub getItemCount {
        return shift->{_fields}->{ItemCount}->{FieldValue};
    }


    sub setItemCount {
        my ($self, $value) = @_;

        $self->{_fields}->{ItemCount}->{FieldValue} = $value;
        return $self;
    }


    sub withItemCount {
        my ($self, $value) = @_;
        $self->setItemCount($value);
        return $self;
    }


    sub isSetItemCount {
        return defined (shift->{_fields}->{ItemCount}->{FieldValue});
    }


    sub getItemNamesSizeBytes {
        return shift->{_fields}->{ItemNamesSizeBytes}->{FieldValue};
    }


    sub setItemNamesSizeBytes {
        my ($self, $value) = @_;

        $self->{_fields}->{ItemNamesSizeBytes}->{FieldValue} = $value;
        return $self;
    }


    sub withItemNamesSizeBytes {
        my ($self, $value) = @_;
        $self->setItemNamesSizeBytes($value);
        return $self;
    }


    sub isSetItemNamesSizeBytes {
        return defined (shift->{_fields}->{ItemNamesSizeBytes}->{FieldValue});
    }


    sub getAttributeNameCount {
        return shift->{_fields}->{AttributeNameCount}->{FieldValue};
    }


    sub setAttributeNameCount {
        my ($self, $value) = @_;

        $self->{_fields}->{AttributeNameCount}->{FieldValue} = $value;
        return $self;
    }


    sub withAttributeNameCount {
        my ($self, $value) = @_;
        $self->setAttributeNameCount($value);
        return $self;
    }


    sub isSetAttributeNameCount {
        return defined (shift->{_fields}->{AttributeNameCount}->{FieldValue});
    }


    sub getAttributeNamesSizeBytes {
        return shift->{_fields}->{AttributeNamesSizeBytes}->{FieldValue};
    }


    sub setAttributeNamesSizeBytes {
        my ($self, $value) = @_;

        $self->{_fields}->{AttributeNamesSizeBytes}->{FieldValue} = $value;
        return $self;
    }


    sub withAttributeNamesSizeBytes {
        my ($self, $value) = @_;
        $self->setAttributeNamesSizeBytes($value);
        return $self;
    }


    sub isSetAttributeNamesSizeBytes {
        return defined (shift->{_fields}->{AttributeNamesSizeBytes}->{FieldValue});
    }


    sub getAttributeValueCount {
        return shift->{_fields}->{AttributeValueCount}->{FieldValue};
    }


    sub setAttributeValueCount {
        my ($self, $value) = @_;

        $self->{_fields}->{AttributeValueCount}->{FieldValue} = $value;
        return $self;
    }


    sub withAttributeValueCount {
        my ($self, $value) = @_;
        $self->setAttributeValueCount($value);
        return $self;
    }


    sub isSetAttributeValueCount {
        return defined (shift->{_fields}->{AttributeValueCount}->{FieldValue});
    }


    sub getAttributeValuesSizeBytes {
        return shift->{_fields}->{AttributeValuesSizeBytes}->{FieldValue};
    }


    sub setAttributeValuesSizeBytes {
        my ($self, $value) = @_;

        $self->{_fields}->{AttributeValuesSizeBytes}->{FieldValue} = $value;
        return $self;
    }


    sub withAttributeValuesSizeBytes {
        my ($self, $value) = @_;
        $self->setAttributeValuesSizeBytes($value);
        return $self;
    }


    sub isSetAttributeValuesSizeBytes {
        return defined (shift->{_fields}->{AttributeValuesSizeBytes}->{FieldValue});
    }


    sub getTimestamp {
        return shift->{_fields}->{Timestamp}->{FieldValue};
    }


    sub setTimestamp {
        my ($self, $value) = @_;

        $self->{_fields}->{Timestamp}->{FieldValue} = $value;
        return $self;
    }


    sub withTimestamp {
        my ($self, $value) = @_;
        $self->setTimestamp($value);
        return $self;
    }


    sub isSetTimestamp {
        return defined (shift->{_fields}->{Timestamp}->{FieldValue});
    }





1;