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
# Select  Sample
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
 # sample for Select Action
 #**********************************************************************/
 use Amazon::SimpleDB::Model::SelectRequest;
 # @TODO: set request. Action can be passed as Amazon::SimpleDB::Model::SelectRequest
 # object or hash of parameters
 # invokeSelect($service, $request);

                                                        
    # 
    # Select Action Sample
    #
  sub invokeSelect {
      my ($service, $request) = @_;  
      eval {
              my $response = $service->select($request);
              
                print ("Service Response\n");
                print ("=============================================================================\n");

                print("        SelectResponse\n");
                if ($response->isSetSelectResult()) { 
                    print("            SelectResult\n");
                    my $selectResult = $response->getSelectResult();
                    my $itemList = $selectResult->getItem();
                    foreach (@$itemList) {
                        my $item = $_;
                        print("                Item\n");
                        if ($item->isSetName()) 
                        {
                            print("                    Name\n");
                            print("                        " . $item->getName() . "\n");
                        }
                        my $attributeList = $item->getAttribute();
                        foreach (@$attributeList) {
                            my $attribute = $_;
                            print("                    Attribute\n");
                            if ($attribute->isSetName()) 
                            {
                                print("                        Name\n");
                                print("                            " . $attribute->getName() . "\n");
                            }
                            if ($attribute->isSetValue()) 
                            {
                                print("                        Value\n");
                                print("                            " . $attribute->getValue() . "\n");
                            }
                        }
                    }
                    if ($selectResult->isSetNextToken()) 
                    {
                        print("                NextToken\n");
                        print("                    " . $selectResult->getNextToken() . "\n");
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

    