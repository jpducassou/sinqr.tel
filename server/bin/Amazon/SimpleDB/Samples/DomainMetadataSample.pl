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



#
# Domain Metadata  Sample
#

use strict;
use Carp qw( carp croak );

# this is only needed when samples are running from directory
# not included in the @INC path
use lib qw(../../../.);  


 #***********************************************************************
 # Access Key ID and Secret Acess Key ID, obtained from:
 # http://aws.amazon.com
 #**********************************************************************/
 
 my $AWS_ACCESS_KEY_ID        = "<Your Access Key ID>";
 my $AWS_SECRET_ACCESS_KEY    = "<Your Secret Access Key>";

 #***********************************************************************
 # Instantiate Http Client Implementation of Simple DB 
 #**********************************************************************/
 use Amazon::SimpleDB::Client; 
 my $service = Amazon::SimpleDB::Client->new($AWS_ACCESS_KEY_ID, $AWS_SECRET_ACCESS_KEY);
 
 #************************************************************************
 # Uncomment to try out Mock Service that simulates Amazon::SimpleDB
 # responses without calling Amazon::SimpleDB service.
 #
 # Responses are loaded from local XML files. You can tweak XML files to
 # experiment with various outputs during development
 #
 # XML files available under Amazon/SimpleDB/Mock tree
 #
 #**********************************************************************/
 # use Amazon::SimpleDB::Mock;  
 # my $service = Amazon::SimpleDB::Mock->new;

 #************************************************************************
 # Setup request parameters and uncomment invoke to try out 
 # sample for Domain Metadata Action
 #**********************************************************************/
 use Amazon::SimpleDB::Model::DomainMetadataRequest;
 # @TODO: set request. Action can be passed as Amazon::SimpleDB::Model::DomainMetadataRequest
 # object or hash of parameters
 # invokeDomainMetadata($service, $request);

                                
    # 
    # Domain Metadata Action Sample
    #
  sub invokeDomainMetadata {
      my ($service, $request) = @_;  
      eval {
              my $response = $service->domainMetadata($request);
              
                print ("Service Response\n");
                print ("=============================================================================\n");

                print("        DomainMetadataResponse\n");
                if ($response->isSetDomainMetadataResult()) { 
                    print("            DomainMetadataResult\n");
                    my $domainMetadataResult = $response->getDomainMetadataResult();
                    if ($domainMetadataResult->isSetItemCount()) 
                    {
                        print("                ItemCount\n");
                        print("                    " . $domainMetadataResult->getItemCount() . "\n");
                    }
                    if ($domainMetadataResult->isSetItemNamesSizeBytes()) 
                    {
                        print("                ItemNamesSizeBytes\n");
                        print("                    " . $domainMetadataResult->getItemNamesSizeBytes() . "\n");
                    }
                    if ($domainMetadataResult->isSetAttributeNameCount()) 
                    {
                        print("                AttributeNameCount\n");
                        print("                    " . $domainMetadataResult->getAttributeNameCount() . "\n");
                    }
                    if ($domainMetadataResult->isSetAttributeNamesSizeBytes()) 
                    {
                        print("                AttributeNamesSizeBytes\n");
                        print("                    " . $domainMetadataResult->getAttributeNamesSizeBytes() . "\n");
                    }
                    if ($domainMetadataResult->isSetAttributeValueCount()) 
                    {
                        print("                AttributeValueCount\n");
                        print("                    " . $domainMetadataResult->getAttributeValueCount() . "\n");
                    }
                    if ($domainMetadataResult->isSetAttributeValuesSizeBytes()) 
                    {
                        print("                AttributeValuesSizeBytes\n");
                        print("                    " . $domainMetadataResult->getAttributeValuesSizeBytes() . "\n");
                    }
                    if ($domainMetadataResult->isSetTimestamp()) 
                    {
                        print("                Timestamp\n");
                        print("                    " . $domainMetadataResult->getTimestamp() . "\n");
                    }
                } 
                if ($response->isSetResponseMetadata()) { 
                    print("            ResponseMetadata\n");
                    my $responseMetadata = $response->getResponseMetadata();
                    if ($responseMetadata->isSetRequestId()) 
                    {
                        print("                RequestId\n");
                        print("                    " . $responseMetadata->getRequestId() . "\n");
                    }
                    if ($responseMetadata->isSetBoxUsage()) 
                    {
                        print("                BoxUsage\n");
                        print("                    " . $responseMetadata->getBoxUsage() . "\n");
                    }
                } 

           
     };
    my $ex = $@;
    if ($ex) {
        require Amazon::SimpleDB::Exception;
        if (ref $ex eq "Amazon::SimpleDB::Exception") {
            print("Caught Exception: " . $ex->getMessage() . "\n");
            print("Response Status Code: " . $ex->getStatusCode() . "\n");
            print("Error Code: " . $ex->getErrorCode() . "\n");
            print("Error Type: " . $ex->getErrorType() . "\n");
            print("Request ID: " . $ex->getRequestId() . "\n");
            print("XML: " . $ex->getXML() . "\n");
        } else {
            croak $@;
        }
    }
 }

                            