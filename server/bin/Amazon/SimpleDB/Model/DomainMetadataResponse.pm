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


package Amazon::SimpleDB::Model::DomainMetadataResponse;

use base qw (Amazon::SimpleDB::Model);

    

    #
    # Amazon::SimpleDB::Model::DomainMetadataResponse
    # 
    # Properties:
    #
    # 
    # DomainMetadataResult: Amazon::SimpleDB::Model::DomainMetadataResult
    # ResponseMetadata: Amazon::SimpleDB::Model::ResponseMetadata
    #
    # 
    # 
    sub new {
        my ($class, $data) = @_;
        my $self = {};
        $self->{_fields} = {
            
            DomainMetadataResult => {FieldValue => undef, FieldType => "Amazon::SimpleDB::Model::DomainMetadataResult"},
            ResponseMetadata => {FieldValue => undef, FieldType => "Amazon::SimpleDB::Model::ResponseMetadata"},
        };

        bless ($self, $class);
        if (defined $data) {
           $self->_fromHashRef($data); 
        }
        
        return $self;
    }

       
     #
     # Construct Amazon::SimpleDB::Model::DomainMetadataResponse from XML string
     # 
    sub fromXML {
        my ($self, $xml) = @_;
        eval "use XML::Simple";
        my $tree = XML::Simple::XMLin ($xml);
         
        # TODO: check valid XML (is this a response XML?)
        
        return new Amazon::SimpleDB::Model::DomainMetadataResponse($tree);
          
    }
    
    sub getDomainMetadataResult {
        return shift->{_fields}->{DomainMetadataResult}->{FieldValue};
    }


    sub setDomainMetadataResult {
        my ($self, $value) = @_;
        $self->{_fields}->{DomainMetadataResult}->{FieldValue} = $value;
    }


    sub withDomainMetadataResult {
        my ($self, $value) = @_;
        $self->setDomainMetadataResult($value);
        return $self;
    }


    sub isSetDomainMetadataResult {
        return defined (shift->{_fields}->{DomainMetadataResult}->{FieldValue});

    }

    sub getResponseMetadata {
        return shift->{_fields}->{ResponseMetadata}->{FieldValue};
    }


    sub setResponseMetadata {
        my ($self, $value) = @_;
        $self->{_fields}->{ResponseMetadata}->{FieldValue} = $value;
    }


    sub withResponseMetadata {
        my ($self, $value) = @_;
        $self->setResponseMetadata($value);
        return $self;
    }


    sub isSetResponseMetadata {
        return defined (shift->{_fields}->{ResponseMetadata}->{FieldValue});

    }



    #
    # XML Representation for this object
    # 
    # Returns string XML for this object
    #
    sub toXML {
        my $self = shift;
        my $xml = "";
        $xml .= "<DomainMetadataResponse xmlns=\"http://sdb.amazonaws.com/doc/2009-04-15/\">";
        $xml .= $self->_toXMLFragment();
        $xml .= "</DomainMetadataResponse>";
        return $xml;
    }


1;