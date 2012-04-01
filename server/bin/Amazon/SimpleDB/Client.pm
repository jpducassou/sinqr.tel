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



package Amazon::SimpleDB::Client;
use strict;
use warnings;
use Digest::SHA qw (hmac_sha1_base64 hmac_sha256_base64);
use XML::Simple;
use LWP::UserAgent;
use URI;
use URI::Escape;
use Time::HiRes qw(usleep);
use Carp qw(croak);
use Amazon::SimpleDB::Exception;

my $SERVICE_VERSION = "2009-04-15";

 #
 # Amazon SimpleDB is a web service for running queries on structured
 # data in real time. This service works in close conjunction with Amazon
 # Simple Storage Service (Amazon S3) and Amazon Elastic Compute Cloud
 # (Amazon EC2), collectively providing the ability to store, process
 # and query data sets in the cloud. These services are designed to make
 # web-scale computing easier and more cost-effective for developers.
 # Traditionally, this type of functionality has been accomplished with
 # a clustered relational database that requires a sizable upfront
 # investment, brings more complexity than is typically needed, and often
 # requires a DBA to maintain and administer. In contrast, Amazon SimpleDB
 # is easy to use and provides the core functionality of a database -
 # real-time lookup and simple querying of structured data without the
 # operational complexity.  Amazon SimpleDB requires no schema, automatically
 # indexes your data and provides a simple API for storage and access.
 # This eliminates the administrative burden of data modeling, index
 # maintenance, and performance tuning. Developers gain access to this
 # functionality within Amazon's proven computing environment, are able
 # to scale instantly, and pay only for what they use.
 # Amazon::SimpleDB::Client is the implementation of service API
 #
 #

    #
    # Construct new Http Client
    #
    # Valid configuration options are:
    #
    # ServiceURL
    # UserAgent
    # SignatureVersion
    # MaxErrorRetry
    # ProxyHost
    # ProxyPort
    # MaxErrorRetry
    #
    sub new {
        my ($class, $awsAccessKeyId, $awsSecretAccessKey, $config) = @_;
        my $defaultConfig =  {
                            ServiceURL => "https://sdb.amazonaws.com",
                            UserAgent => "Amazon SimpleDB Perl Library",
                            SignatureVersion => 2,
                            SignatureMethod => "HmacSHA256",
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

    # Public API ------------------------------------------------------------#


            
    #
    # Create Domain 
    # The CreateDomain operation creates a new domain. The domain name must be unique
    # among the domains associated with the Access Key ID provided in the request. The CreateDomain
    # operation may take 10 or more seconds to complete.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_CreateDomain.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::CreateDomainRequest request
    # or Amazon::SimpleDB::Model::CreateDomainRequest object itself
    # See Amazon::SimpleDB::Model::CreateDomainRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::CreateDomainResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub createDomain {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::CreateDomainRequest") {
            require Amazon::SimpleDB::Model::CreateDomainRequest;
            $request = Amazon::SimpleDB::Model::CreateDomainRequest->new($request);
        }
        require Amazon::SimpleDB::Model::CreateDomainResponse;
        return Amazon::SimpleDB::Model::CreateDomainResponse->fromXML($self->_invoke($self->_convertCreateDomain($request)));
    }


            
    #
    # List Domains 
    # The ListDomains operation lists all domains associated with the Access Key ID. It returns
    # domain names up to the limit set by MaxNumberOfDomains. A NextToken is returned if there are more
    # than MaxNumberOfDomains domains. Calling ListDomains successive times with the
    # NextToken returns up to MaxNumberOfDomains more domain names each time.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_ListDomains.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::ListDomainsRequest request
    # or Amazon::SimpleDB::Model::ListDomainsRequest object itself
    # See Amazon::SimpleDB::Model::ListDomainsRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::ListDomainsResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub listDomains {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::ListDomainsRequest") {
            require Amazon::SimpleDB::Model::ListDomainsRequest;
            $request = Amazon::SimpleDB::Model::ListDomainsRequest->new($request);
        }
        require Amazon::SimpleDB::Model::ListDomainsResponse;
        return Amazon::SimpleDB::Model::ListDomainsResponse->fromXML($self->_invoke($self->_convertListDomains($request)));
    }


            
    #
    # Domain Metadata 
    # The DomainMetadata operation returns some domain metadata values, such as the
    # number of items, attribute names and attribute values along with their sizes.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_DomainMetadata.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::DomainMetadataRequest request
    # or Amazon::SimpleDB::Model::DomainMetadataRequest object itself
    # See Amazon::SimpleDB::Model::DomainMetadataRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::DomainMetadataResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub domainMetadata {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::DomainMetadataRequest") {
            require Amazon::SimpleDB::Model::DomainMetadataRequest;
            $request = Amazon::SimpleDB::Model::DomainMetadataRequest->new($request);
        }
        require Amazon::SimpleDB::Model::DomainMetadataResponse;
        return Amazon::SimpleDB::Model::DomainMetadataResponse->fromXML($self->_invoke($self->_convertDomainMetadata($request)));
    }


            
    #
    # Delete Domain 
    # The DeleteDomain operation deletes a domain. Any items (and their attributes) in the domain
    # are deleted as well. The DeleteDomain operation may take 10 or more seconds to complete.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_DeleteDomain.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::DeleteDomainRequest request
    # or Amazon::SimpleDB::Model::DeleteDomainRequest object itself
    # See Amazon::SimpleDB::Model::DeleteDomainRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::DeleteDomainResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub deleteDomain {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::DeleteDomainRequest") {
            require Amazon::SimpleDB::Model::DeleteDomainRequest;
            $request = Amazon::SimpleDB::Model::DeleteDomainRequest->new($request);
        }
        require Amazon::SimpleDB::Model::DeleteDomainResponse;
        return Amazon::SimpleDB::Model::DeleteDomainResponse->fromXML($self->_invoke($self->_convertDeleteDomain($request)));
    }


            
    #
    # Put Attributes 
    # The PutAttributes operation creates or replaces attributes within an item. You specify new attributes
    # using a combination of the Attribute.X.Name and Attribute.X.Value parameters. You specify
    # the first attribute by the parameters Attribute.0.Name and Attribute.0.Value, the second
    # attribute by the parameters Attribute.1.Name and Attribute.1.Value, and so on.
    # Attributes are uniquely identified within an item by their name/value combination. For example, a single
    # item can have the attributes { "first_name", "first_value" } and { "first_name",
    # second_value" }. However, it cannot have two attribute instances where both the Attribute.X.Name and
    # Attribute.X.Value are the same.
    # Optionally, the requestor can supply the Replace parameter for each individual value. Setting this value
    # to true will cause the new attribute value to replace the existing attribute value(s). For example, if an
    # item has the attributes { 'a', '1' }, { 'b', '2'} and { 'b', '3' } and the requestor does a
    # PutAttributes of { 'b', '4' } with the Replace parameter set to true, the final attributes of the
    # item will be { 'a', '1' } and { 'b', '4' }, replacing the previous values of the 'b' attribute
    # with the new value.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_PutAttributes.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::PutAttributesRequest request
    # or Amazon::SimpleDB::Model::PutAttributesRequest object itself
    # See Amazon::SimpleDB::Model::PutAttributesRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::PutAttributesResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub putAttributes {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::PutAttributesRequest") {
            require Amazon::SimpleDB::Model::PutAttributesRequest;
            $request = Amazon::SimpleDB::Model::PutAttributesRequest->new($request);
        }
        require Amazon::SimpleDB::Model::PutAttributesResponse;
        return Amazon::SimpleDB::Model::PutAttributesResponse->fromXML($self->_invoke($self->_convertPutAttributes($request)));
    }


            
    #
    # Batch Put Attributes 
    # The BatchPutAttributes operation creates or replaces attributes within one or more items.
    # You specify the item name with the Item.X.ItemName parameter.
    # You specify new attributes using a combination of the Item.X.Attribute.Y.Name and Item.X.Attribute.Y.Value parameters.
    # You specify the first attribute for the first item by the parameters Item.0.Attribute.0.Name and Item.0.Attribute.0.Value,
    # the second attribute for the first item by the parameters Item.0.Attribute.1.Name and Item.0.Attribute.1.Value, and so on.
    # Attributes are uniquely identified within an item by their name/value combination. For example, a single
    # item can have the attributes { "first_name", "first_value" } and { "first_name",
    # second_value" }. However, it cannot have two attribute instances where both the Item.X.Attribute.Y.Name and
    # Item.X.Attribute.Y.Value are the same.
    # Optionally, the requestor can supply the Replace parameter for each individual value. Setting this value
    # to true will cause the new attribute value to replace the existing attribute value(s). For example, if an
    # item 'I' has the attributes { 'a', '1' }, { 'b', '2'} and { 'b', '3' } and the requestor does a
    # BacthPutAttributes of {'I', 'b', '4' } with the Replace parameter set to true, the final attributes of the
    # item will be { 'a', '1' } and { 'b', '4' }, replacing the previous values of the 'b' attribute
    # with the new value.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_BatchPutAttributes.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::BatchPutAttributesRequest request
    # or Amazon::SimpleDB::Model::BatchPutAttributesRequest object itself
    # See Amazon::SimpleDB::Model::BatchPutAttributesRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::BatchPutAttributesResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub batchPutAttributes {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::BatchPutAttributesRequest") {
            require Amazon::SimpleDB::Model::BatchPutAttributesRequest;
            $request = Amazon::SimpleDB::Model::BatchPutAttributesRequest->new($request);
        }
        require Amazon::SimpleDB::Model::BatchPutAttributesResponse;
        return Amazon::SimpleDB::Model::BatchPutAttributesResponse->fromXML($self->_invoke($self->_convertBatchPutAttributes($request)));
    }


            
    #
    # Get Attributes 
    # Returns all of the attributes associated with the item. Optionally, the attributes returned can be limited to
    # the specified AttributeName parameter.
    # If the item does not exist on the replica that was accessed for this operation, an empty attribute is
    # returned. The system does not return an error as it cannot guarantee the item does not exist on other
    # replicas.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_GetAttributes.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::GetAttributesRequest request
    # or Amazon::SimpleDB::Model::GetAttributesRequest object itself
    # See Amazon::SimpleDB::Model::GetAttributesRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::GetAttributesResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub getAttributes {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::GetAttributesRequest") {
            require Amazon::SimpleDB::Model::GetAttributesRequest;
            $request = Amazon::SimpleDB::Model::GetAttributesRequest->new($request);
        }
        require Amazon::SimpleDB::Model::GetAttributesResponse;
        return Amazon::SimpleDB::Model::GetAttributesResponse->fromXML($self->_invoke($self->_convertGetAttributes($request)));
    }


            
    #
    # Delete Attributes 
    # Deletes one or more attributes associated with the item. If all attributes of an item are deleted, the item is
    # deleted.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_DeleteAttributes.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::DeleteAttributesRequest request
    # or Amazon::SimpleDB::Model::DeleteAttributesRequest object itself
    # See Amazon::SimpleDB::Model::DeleteAttributesRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::DeleteAttributesResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub deleteAttributes {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::DeleteAttributesRequest") {
            require Amazon::SimpleDB::Model::DeleteAttributesRequest;
            $request = Amazon::SimpleDB::Model::DeleteAttributesRequest->new($request);
        }
        require Amazon::SimpleDB::Model::DeleteAttributesResponse;
        return Amazon::SimpleDB::Model::DeleteAttributesResponse->fromXML($self->_invoke($self->_convertDeleteAttributes($request)));
    }


            
    #
    # Select 
    # The Select operation returns a set of item names and associate attributes that match the
    # query expression. Select operations that run longer than 5 seconds will likely time-out
    # and return a time-out error response.
    # See http://docs.amazonwebservices.com/AmazonSimpleDB/2009-04-15/DeveloperGuide/SDB_API_Select.html
    # Argument either hash reference of parameters for Amazon::SimpleDB::Model::SelectRequest request
    # or Amazon::SimpleDB::Model::SelectRequest object itself
    # See Amazon::SimpleDB::Model::SelectRequest for valid arguments
    # Returns Amazon::SimpleDB::Model::SelectResponse
    #
    # throws Amazon::SimpleDB::Exception. Use eval to catch it
    #
    sub select {
        my ($self, $request) = @_;
        if (not ref $request eq "Amazon::SimpleDB::Model::SelectRequest") {
            require Amazon::SimpleDB::Model::SelectRequest;
            $request = Amazon::SimpleDB::Model::SelectRequest->new($request);
        }
        require Amazon::SimpleDB::Model::SelectResponse;
        return Amazon::SimpleDB::Model::SelectResponse->fromXML($self->_invoke($self->_convertSelect($request)));
    }

    # Private API ------------------------------------------------------------#

    #
    # Invoke request and return response
    #
    sub _invoke {
        my ($self, $parameters) = @_;
        my $actionName = $parameters->{Action};
        my $response = undef;
        my $statusCode = 200;

        # Add required request parameters #
        $parameters = $self->_addRequiredParameters($parameters);

        my $retries = 0;
        my $shouldRetry = 1;

        eval {
            do {
                # Submit the request and read response body #
                eval {
                    $response = $self->_httpPost($parameters);
                    if ($response->is_success) {
                        $shouldRetry = 0;
                    } else {
                        if ($response->code == 500 || $response->code == 503) {
                            $shouldRetry = 1;
                            $self->_pauseOnRetry(++$retries, $response->code);
                        } else {
                            my $ex = $self->_reportAnyErrors($response->content, $response->code);
                            Carp::croak ($ex) if ($ex);
                        }
                    }
                };
                my $e = $@;
                if ($e) {
                    if (ref $e eq "Amazon::SimpleDB::Exception") {
                        Carp::croak $e;
                    } else {
                        Carp::croak (Amazon::SimpleDB::Exception->new ({Message => $e}));
                    }
                }
            } while ($shouldRetry);
        };
        my $e = $@;
        if ($e) {
            if (ref $e eq "Amazon::SimpleDB::Exception") {
                Carp::croak $e;
            } else {
                Carp::croak (Amazon::SimpleDB::Exception->new ({Message => $e}));
            }
        }
        return $response->content;
    }

    #
    # Exponential sleep on failed request
    # Retries - current retry
    # throws Amazon::SimpleDB::Exception if maximum number of retries has been reached
    #
    sub _pauseOnRetry {
        my ($self, $retries, $status) = @_;
        if ($retries <= $self->{_config}->{MaxErrorRetry}) {
            my $delay = (4 ** $retries) * 100000 ;
            usleep($delay);
        } else {
            Carp::croak new Amazon::SimpleDB::Exception ({Message => "Maximum number of retry attempts reached :  " . ($retries - 1),
            StatusCode => $status});
        }
    }

    #
    # Look for additional error strings in the response and return formatted exception
    #
    sub _reportAnyErrors {
        my ($self, $responseBody, $status, $e) = @_;
        my $ex = undef;
        if (defined($responseBody) and $responseBody =~ m/</) {
            if ($responseBody =~ m/<RequestId>(.*)<\/RequestId>.*<Error><Code>(.*)<\/Code><Message>(.*)<\/Message><\/Error>.*(<Error>)?/msg) {

                my $requestId = $1;
                my $code = $2;
                my $message = $3;
                $ex = Amazon::SimpleDB::Exception->new ({Message => $message,
                                                              StatusCode => $status,
                					      ErrorCode => $code,
                                                              ErrorType => "Unknown",
                                                              RequestId => $requestId,
                                                              XML => $responseBody});

            } elsif ($responseBody =~ m/<Error><Code>(.*)<\/Code><Message>(.*)<\/Message><\/Error>.*(<Error>)?.*<RequestID>(.*)<\/RequestID>/msg) {

                my $code = $1;
                my $message = $2;
                my $requestId = $4;
                $ex = Amazon::SimpleDB::Exception->new({Message => $message,
                                                           StatusCode => $status,
                                                           ErrorCode => $code,
                                                           ErrorType => "Unknown",
                                                           RequestId => $requestId,
                                                           XML => $responseBody});
            } elsif ($responseBody =~ m/<Error><Code>(.*)<\/Code><Message>(.*)<\/Message><BoxUsage>(.*)<\/BoxUsage><\/Error>.*(<Error>)?.*<RequestID>(.*)<\/RequestID>/msg) {

                my $code = $1;
                my $message = $2;
                my $boxUsage = $3;
                my $requestId = $5;
                $ex = Amazon::SimpleDB::Exception->new({Message => $message,
                                                        StatusCode => $status,
                                                        ErrorCode => $code,
                                                        ErrorType => "Unknown",
                                                        BoxUsage => $boxUsage,
                                                        RequestId => $requestId,
                                                        XML => $responseBody});
            } else {
                $ex = Amazon::SimpleDB::Exception->new({
                                                        Message => "Internal Error",
                                                        StatusCode => $status});
            }
        } else {
            $ex = Amazon::SimpleDB::Exception->new({
                                                Message => "Internal Error",
                                                StatusCode => $status});
        }
        return $ex;
    }

    #
    # perform http post
    #
    sub _httpPost {
	my ($self, $parameters) = @_;
        my $url = $self->{_config}->{ServiceURL};
        require LWP::UserAgent;
        my $ua = LWP::UserAgent->new;
	my $request= HTTP::Request->new("POST", $url);
	$request->content_type("application/x-www-form-urlencoded; charset=utf-8");
	my $data = "";
    	foreach my $parameterName (keys %$parameters) {
   	    no warnings "uninitialized";
   	    $data .= $parameterName .  "="  . $self->_urlencode($parameters->{$parameterName}, 0);
       	    $data .= "&";
   	}
    	chop ($data);
	$request->content($data);
	my $response = $ua->request($request);
        return $response;
    }

    #
    # Add authentication related and version parameters
    #
    sub _addRequiredParameters {
   	my ($self,  $parameters) = @_;
        $parameters->{AWSAccessKeyId} = $self->{_awsAccessKeyId};
        $parameters->{Timestamp} = $self->_getFormattedTimestamp();
        $parameters->{Version} = $SERVICE_VERSION;
        $parameters->{SignatureVersion} = $self->{_config}->{SignatureVersion} || "1";
        $parameters->{Signature} = $self->_signParameters($parameters, $self->{_awsSecretAccessKey});

        return $parameters;
    }

    #
    # Computes RFC 2104-compliant HMAC signature for request parameters
    # Implements AWS Signature, as per following spec:
    #
    # If Signature Version is 0, it signs concatenated Action and Timestamp
    #
    # If Signature Version is 1, it performs the following:
    #
    # Sorts all  parameters (including SignatureVersion and excluding Signature,
    # the value of which is being created), ignoring case.
    #
    # Iterate over the sorted list and append the parameter name (in original case)
    # and then its value. It will not URL-encode the parameter values before
    # constructing this string. There are no separators.
    #
    sub _signParameters {
     	my ($self, $parameters, $key)  = @_;
        my $algorithm = "HmacSHA1";
        my $data = "";
        my $signatureVersion = $parameters->{SignatureVersion};
        if ("0" eq $signatureVersion) {
            $data =  $self->_calculateStringToSignV0($parameters);
        } elsif ("1" eq $signatureVersion) {
            $data = $self->_calculateStringToSignV1($parameters);
        } elsif ("2" eq $signatureVersion) {
            $algorithm = $self->{_config}->{SignatureMethod};
            $parameters->{SignatureMethod} = $algorithm;
            $data = $self->_calculateStringToSignV2($parameters);
        } else {
            Carp::croak ("Invalid Signature Version specified");
        }
        return $self->_sign($data, $key, $algorithm);
    }


    sub _calculateStringToSignV0 {
        my ($self, $parameters)  = @_;
        return $parameters->{Action} .  $parameters->{Timestamp};
    }


    sub _calculateStringToSignV1 {
        my ($self, $parameters)  = @_;
        my $data = "";
        foreach my $parameterName (sort { lc($a) cmp lc($b) } keys %$parameters) {
            no warnings "uninitialized";
        	$data .= $parameterName . $parameters->{$parameterName};
        }
        return $data;
    }

    sub _calculateStringToSignV2  {
        my ($self, $parameters)  = @_;
        my $endpoint = URI->new ($self->{_config}->{ServiceURL});
        my $data = "POST";
        $data .= "\n";
        $data .= $endpoint->host;
        $data .= "\n";
        my $path =  $endpoint->path || "/";
        $data .= $self->_urlencode($path, 1);
        $data .= "\n";
        my @parameterKeys =   keys %$parameters;
        foreach my $parameterName (sort { $a cmp $b } @parameterKeys ) {
            no warnings "uninitialized";
            $data .= $parameterName .  "="  . $self->_urlencode($parameters->{$parameterName});
            $data .= "&";
        }
        chop ($data);
        return $data;
    }

    sub _urlencode {
	my ($self, $value, $path) = @_;
	use URI::Escape qw(uri_escape_utf8);
	my $escapepattern = "^A-Za-z0-9\-_.~";
	if ($path) {
	    $escapepattern = $escapepattern .  "/";
	}
	return uri_escape_utf8($value, $escapepattern);
    }

    #
    # Computes RFC 2104-compliant HMAC signature.
    #
    sub  _sign {
        my ($self, $data, $key, $algorithm) = @_;
        my $output = "";
        if ("HmacSHA1" eq $algorithm) {
           $output  =  hmac_sha1_base64 ($data, $key);
        } elsif ("HmacSHA256" eq $algorithm) {
            $output = hmac_sha256_base64 ($data, $key);
        } else {
         	Carp::croak ("Non-supported signing method specified");
        }
        return $output . "=";
    }

    #
    # Formats date as ISO 8601 timestamp
    #
    sub _getFormattedTimestamp {
        return sprintf("%04d-%02d-%02dT%02d:%02d:%02d.000Z",
        sub {    ($_[5]+1900,
                 $_[4]+1,
                 $_[3],
                 $_[2],
                 $_[1],
                 $_[0])
           }->(gmtime(time)));
    }

                                                                                        
    #
    # Convert CreateDomainRequest to name value pairs
    #
    sub _convertCreateDomain() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "CreateDomain";
        if ($request->isSetDomainName()) {
            $parameters->{"DomainName"} =  $request->getDomainName();
        }

        return $parameters;
    }
        
                                        
    #
    # Convert ListDomainsRequest to name value pairs
    #
    sub _convertListDomains() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "ListDomains";
        if ($request->isSetMaxNumberOfDomains()) {
            $parameters->{"MaxNumberOfDomains"} =  $request->getMaxNumberOfDomains();
        }
        if ($request->isSetNextToken()) {
            $parameters->{"NextToken"} =  $request->getNextToken();
        }

        return $parameters;
    }
        
                                                
    #
    # Convert DomainMetadataRequest to name value pairs
    #
    sub _convertDomainMetadata() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "DomainMetadata";
        if ($request->isSetDomainName()) {
            $parameters->{"DomainName"} =  $request->getDomainName();
        }

        return $parameters;
    }
        
                                                
    #
    # Convert DeleteDomainRequest to name value pairs
    #
    sub _convertDeleteDomain() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "DeleteDomain";
        if ($request->isSetDomainName()) {
            $parameters->{"DomainName"} =  $request->getDomainName();
        }

        return $parameters;
    }
        
                                        
    #
    # Convert PutAttributesRequest to name value pairs
    #
    sub _convertPutAttributes() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "PutAttributes";
        if ($request->isSetDomainName()) {
            $parameters->{"DomainName"} =  $request->getDomainName();
        }
        if ($request->isSetItemName()) {
            $parameters->{"ItemName"} =  $request->getItemName();
        }
        my $attributeputAttributesRequestList = $request->getAttribute();
        for my $attributeputAttributesRequestIndex (0 .. $#{$attributeputAttributesRequestList}) {
            my $attributeputAttributesRequest = $attributeputAttributesRequestList->[$attributeputAttributesRequestIndex];
            if ($attributeputAttributesRequest->isSetName()) {
                $parameters->{"Attribute" . "."  . ($attributeputAttributesRequestIndex + 1) . "." . "Name"} =  $attributeputAttributesRequest->getName();
            }
            if ($attributeputAttributesRequest->isSetValue()) {
                $parameters->{"Attribute" . "."  . ($attributeputAttributesRequestIndex + 1) . "." . "Value"} =  $attributeputAttributesRequest->getValue();
            }
            if ($attributeputAttributesRequest->isSetReplace()) {
                $parameters->{"Attribute" . "."  . ($attributeputAttributesRequestIndex + 1) . "." . "Replace"} =  $attributeputAttributesRequest->getReplace() ? "true" : "false";
            }

        }
        if ($request->isSetExpected()) {
            my $expectedputAttributesRequest = $request->getExpected();
            if ($expectedputAttributesRequest->isSetName()) {
                $parameters->{"Expected" . "." . "Name"} =  $expectedputAttributesRequest->getName();
            }
            if ($expectedputAttributesRequest->isSetValue()) {
                $parameters->{"Expected" . "." . "Value"} =  $expectedputAttributesRequest->getValue();
            }
            if ($expectedputAttributesRequest->isSetExists()) {
                $parameters->{"Expected" . "." . "Exists"} =  $expectedputAttributesRequest->getExists() ? "true" : "false";
            }
        }

        return $parameters;
    }
        
                                        
    #
    # Convert BatchPutAttributesRequest to name value pairs
    #
    sub _convertBatchPutAttributes() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "BatchPutAttributes";
        if ($request->isSetDomainName()) {
            $parameters->{"DomainName"} =  $request->getDomainName();
        }
        my $itembatchPutAttributesRequestList = $request->getItem();
        for my $itembatchPutAttributesRequestIndex (0 .. $#{$itembatchPutAttributesRequestList}) {
            my $itembatchPutAttributesRequest = $itembatchPutAttributesRequestList->[$itembatchPutAttributesRequestIndex];
            if ($itembatchPutAttributesRequest->isSetItemName()) {
                $parameters->{"Item" . "."  . ($itembatchPutAttributesRequestIndex + 1) . "." . "ItemName"} =  $itembatchPutAttributesRequest->getItemName();
            }
            my $attributeitemList = $itembatchPutAttributesRequest->getAttribute();
            for my $attributeitemIndex (0 .. $#{$attributeitemList}) {
                my $attributeitem = $attributeitemList->[$attributeitemIndex];
                if ($attributeitem->isSetName()) {
                    $parameters->{"Item" . "."  . ($itembatchPutAttributesRequestIndex + 1) . "." . "Attribute" . "."  . ($attributeitemIndex + 1) . "." . "Name"} =  $attributeitem->getName();
                }
                if ($attributeitem->isSetValue()) {
                    $parameters->{"Item" . "."  . ($itembatchPutAttributesRequestIndex + 1) . "." . "Attribute" . "."  . ($attributeitemIndex + 1) . "." . "Value"} =  $attributeitem->getValue();
                }
                if ($attributeitem->isSetReplace()) {
                    $parameters->{"Item" . "."  . ($itembatchPutAttributesRequestIndex + 1) . "." . "Attribute" . "."  . ($attributeitemIndex + 1) . "." . "Replace"} =  $attributeitem->getReplace() ? "true" : "false";
                }

            }

        }

        return $parameters;
    }
        
                                        
    #
    # Convert GetAttributesRequest to name value pairs
    #
    sub _convertGetAttributes() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "GetAttributes";
        if ($request->isSetDomainName()) {
            $parameters->{"DomainName"} =  $request->getDomainName();
        }
        if ($request->isSetItemName()) {
            $parameters->{"ItemName"} =  $request->getItemName();
        }
        my $attributeNamegetAttributesRequestList = $request->getAttributeName();
        for my $attributeNamegetAttributesRequestIndex (0 .. $#{$attributeNamegetAttributesRequestList}) {
            my $attributeNamegetAttributesRequest = $attributeNamegetAttributesRequestList->[$attributeNamegetAttributesRequestIndex];
            $parameters->{"AttributeName" . "."  . ($attributeNamegetAttributesRequestIndex + 1)} =  $attributeNamegetAttributesRequest;
        }
        if ($request->isSetConsistentRead()) {
            $parameters->{"ConsistentRead"} =  $request->getConsistentRead() ? "true" : "false";
        }

        return $parameters;
    }
        
                                                
    #
    # Convert DeleteAttributesRequest to name value pairs
    #
    sub _convertDeleteAttributes() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "DeleteAttributes";
        if ($request->isSetDomainName()) {
            $parameters->{"DomainName"} =  $request->getDomainName();
        }
        if ($request->isSetItemName()) {
            $parameters->{"ItemName"} =  $request->getItemName();
        }
        my $attributedeleteAttributesRequestList = $request->getAttribute();
        for my $attributedeleteAttributesRequestIndex (0 .. $#{$attributedeleteAttributesRequestList}) {
            my $attributedeleteAttributesRequest = $attributedeleteAttributesRequestList->[$attributedeleteAttributesRequestIndex];
            if ($attributedeleteAttributesRequest->isSetName()) {
                $parameters->{"Attribute" . "."  . ($attributedeleteAttributesRequestIndex + 1) . "." . "Name"} =  $attributedeleteAttributesRequest->getName();
            }
            if ($attributedeleteAttributesRequest->isSetValue()) {
                $parameters->{"Attribute" . "."  . ($attributedeleteAttributesRequestIndex + 1) . "." . "Value"} =  $attributedeleteAttributesRequest->getValue();
            }

        }
        if ($request->isSetExpected()) {
            my $expecteddeleteAttributesRequest = $request->getExpected();
            if ($expecteddeleteAttributesRequest->isSetName()) {
                $parameters->{"Expected" . "." . "Name"} =  $expecteddeleteAttributesRequest->getName();
            }
            if ($expecteddeleteAttributesRequest->isSetValue()) {
                $parameters->{"Expected" . "." . "Value"} =  $expecteddeleteAttributesRequest->getValue();
            }
            if ($expecteddeleteAttributesRequest->isSetExists()) {
                $parameters->{"Expected" . "." . "Exists"} =  $expecteddeleteAttributesRequest->getExists() ? "true" : "false";
            }
        }

        return $parameters;
    }
        
                                        
    #
    # Convert SelectRequest to name value pairs
    #
    sub _convertSelect() {
        my ($self, $request) = @_;
        
        my $parameters = {};
        $parameters->{"Action"} = "Select";
        if ($request->isSetSelectExpression()) {
            $parameters->{"SelectExpression"} =  $request->getSelectExpression();
        }
        if ($request->isSetNextToken()) {
            $parameters->{"NextToken"} =  $request->getNextToken();
        }
        if ($request->isSetConsistentRead()) {
            $parameters->{"ConsistentRead"} =  $request->getConsistentRead() ? "true" : "false";
        }

        return $parameters;
    }
        
                        
1;
