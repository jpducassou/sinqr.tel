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



package  Amazon::SimpleDB::Mock;
{
   # Public API ------------------------------------------------------------#
    sub new {
        my ($class, $awsAccessKeyId, $awsSecretAccessKey, $config) = @_;
        my $defaultConfig =  {
                            ServiceURL => "https://sdb.amazonaws.com",
                            UserAgent => "Amazon SimpleDB Perl Library",
                            SignatureVersion => 1,
                            ProxyHost => undef,
                            ProxyPort => -1,
                            MaxErrorRetry => 3
                          };
        my $self = {};
        $self->{_awsAccessKeyId} = $awsAccessKeyId;
        $self->{_awsSecretAccessKey} = $awsSecretAccessKey;
        $self->{_config} = $defaultConfig;
        $self->{_config} = {%$defaultConfig, %$config} if defined ($config);

        return bless ($self, $class);
    }

            
    sub createDomain {
        require Amazon::SimpleDB::Model::CreateDomainResponse;
        return Amazon::SimpleDB::Model::CreateDomainResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/CreateDomainResponse.xml"});
    }


            
    sub listDomains {
        require Amazon::SimpleDB::Model::ListDomainsResponse;
        return Amazon::SimpleDB::Model::ListDomainsResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/ListDomainsResponse.xml"});
    }


            
    sub domainMetadata {
        require Amazon::SimpleDB::Model::DomainMetadataResponse;
        return Amazon::SimpleDB::Model::DomainMetadataResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/DomainMetadataResponse.xml"});
    }


            
    sub deleteDomain {
        require Amazon::SimpleDB::Model::DeleteDomainResponse;
        return Amazon::SimpleDB::Model::DeleteDomainResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/DeleteDomainResponse.xml"});
    }


            
    sub putAttributes {
        require Amazon::SimpleDB::Model::PutAttributesResponse;
        return Amazon::SimpleDB::Model::PutAttributesResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/PutAttributesResponse.xml"});
    }


            
    sub batchPutAttributes {
        require Amazon::SimpleDB::Model::BatchPutAttributesResponse;
        return Amazon::SimpleDB::Model::BatchPutAttributesResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/BatchPutAttributesResponse.xml"});
    }


            
    sub getAttributes {
        require Amazon::SimpleDB::Model::GetAttributesResponse;
        return Amazon::SimpleDB::Model::GetAttributesResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/GetAttributesResponse.xml"});
    }


            
    sub deleteAttributes {
        require Amazon::SimpleDB::Model::DeleteAttributesResponse;
        return Amazon::SimpleDB::Model::DeleteAttributesResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/DeleteAttributesResponse.xml"});
    }


            
    sub select {
        require Amazon::SimpleDB::Model::SelectResponse;
        return Amazon::SimpleDB::Model::SelectResponse
                    ->fromXML ($INC{"Amazon/SimpleDB/Mock/SelectResponse.xml"});
    }

}

1;