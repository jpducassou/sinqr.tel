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



package Amazon::SimpleDB::Util;

use strict;
use warnings;
use Time::Local qw(timegm timelocal);

sub encodeZeroPadding {
    my ($number,$maxNumDigits) = @_;
    if (int($number) == $number) {
        return sprintf("%0${maxNumDigits}d",$number);
    } else {
        $number =~ /\.(.*)/;
        my $dec = length($1);
        $maxNumDigits += $dec + 1;
        return sprintf("%0${maxNumDigits}.${dec}f",$number);
    } 
}

sub encodeRealNumberRange {
    my ($number, $maxDigitsLeft, $maxDigitsRight, $offsetValue) = @_;
    my $shiftMultiplier = 10**$maxDigitsRight;
    my $shiftedNumber = int((($number + $offsetValue) * $shiftMultiplier) + 0.5); # Note: int(x+.5) is a makeshift round
    my $padLength = $maxDigitsLeft + $maxDigitsRight;
    return sprintf("%0${padLength}d",$shiftedNumber);
}

sub decodeZeroPaddingInt  {
	return int(shift);
}

sub decodeZeroPaddingFloat {
    my $value = shift;
    return $value * 1;
}

sub decodeRealNumberRangeInt  {
    my ($value,$offsetValue) = @_;
    return int($value) - $offsetValue;
}

sub decodeRealNumberRangeFloat  {
    my ($value, $maxDigitsRight, $offsetValue) = @_;
    return int($value) / (10**$maxDigitsRight) - $offsetValue;
}

sub encodeDate($) {
    my $time = shift;
    my ($sec, $min, $hour, $day, $mon, $year) = localtime($time);
    my $msec = int(($time - int($time)) * 1000 + 0.5);
    # Figure out timezone.
    my $tz;
    my $tz_sec = timegm(localtime()) - time();
    my $tz_min = $tz_sec % 3600;
    my $tz_hr  = ($tz_sec - $tz_min) / 3600;
    $tz_min = int($tz_min/60);

    if (abs($tz_sec) != $tz_sec) {
        $tz = sprintf("-%02d:%02d",abs($tz_hr),$tz_min);
    } else {
        $tz = sprintf("+%02d:%02d",$tz_hr,$tz_min);
    }
    return sprintf("%04d-%02d-%02dT%02d:%02d:%02d.%03d%s",$year+1900,$mon+1,$day,$hour,$min,$sec,$msec,$tz);
}

sub decodeDate  {
    my $value = shift;
    if ($value =~ /^([0-9]{4,4})\-([0-9]{2,2})\-([0-9]{2,2})T([0-9]{2,2}):([0-9]{2,2}):([0-9]{2,2})\.([0-9]{3,3})([\-\+][0-9]{2,2})\:([0-9]{2,2})$/) {
        my ($year,$mon,$day,$hour,$min,$sec,$msec,$tz_hr,$tz_min) = ($1,$2,$3,$4,$5,$6,$7,$8,$9);
        my $tz = (int($tz_hr) * 3600) + (int($tz_min) * 60);
        my $tz_diff = (timegm(localtime()) - time()) - $tz;
        return (timelocal($sec,$min,$hour,$day,$mon-1,$year-1900) + $tz_diff) . ".$msec";
    }
    return undef;
}

1;

__END__

=head1 NAME

Amazon::SimpleDB::Util - A collection of functions for conversion of various values into strings that may be compared lexicographically

=head1 SYNOPSIS

Amazon::SimpleDB::Util::encodeZeroPadding(123,6); # 000123
Amazon::SimpleDB::Util::encodeRealNumberRange(-123.456,10,4,1000); # 00000008765440
Amazon::SimpleDB::Util::decodeRealNumberRangeFloat("00000008765440",4,1000); # -123.456
Amazon::SimpleDB::Util::encodeDate(1197338156.124); # 2007-12-10T17:53:58.124-08:00, if you're in the Pacific time zone. (1:53:58.124 AM, Dec 11 2007 GMT)
Amazon::SimpleDB::Util::decodeDate("2007-12-10T17:53:58.124-08:00"); # 1197338156.124, if you're in the Pacific time zone.

=head1 DESCRIPTION

=head2 encodeZeroPadding

encodeZeroPadding encodes a positive integer or floating point value into a string by zero-padding number up to the specified number of digits.
 
param positive integer or floating point value to be encoded
param maximum number of digits in the largest value in the data set
return string representation of the zero-padded integer or floating point value

=head2 decodeZeroPaddingInt

decodeZeroPaddingInt decodes zero-padded positive integer value from the string representation

param zero-padded string representation of the integer
return original integer value

=head2 decodeZeroPaddingFloat

decodeZeroPaddingFloat decodes a zero-padded positive float value from the string representation
 
param zero-padded string representation of the float value
return original floating point value

=head2 encodeRealNumberRange

encodeRealNumberRange encodes a real number value into a string by offsetting
and zero-padding the number up to the specified number of digits.  Use this
encoding method if the data range set includes both positive and negative
values.

This function handles both float and int values.

param integer|float real number to be encoded
param integer maximum number of digits left of the decimal point in the largest absolute value in the data set
param integer maximum number of digits right of the decimal point in the largest absolute value in the data set, i.e. precision
param integer offset value, has to be greater than absolute value of any negative number in the data set.
return string representation of the integer

=head2 decodeRealNumberRangeInt

decodeRealNumberRangeInt decodes integer value from the string representation
that was created by using encodeRealNumberRange(..) function.

param string representation of the integer value
param integer offset value that was used in the original encoding
return integer original integer value

=head2 decodeRealNumberRangeFloat

decodeRealNumberRangeFloat decodes a floating point value from the string
representation that was created by using encodeRealNumberRange(..) function.

param string representation of the floating point value
param maximum number of digits left of the decimal point in the largest absolute value in the data set (must be the same as the one used for encoding).
param offset value that was used in the original encoding
return float original floating point value

=head2 encodeDate

encodeDate encodes date value into string format that can be compared
lexicographically. Result is an ISO8601 compatible string.

param unix timestamp from the local timezone to be encoded. May include milliseconds as a fraction.
return string representation of the date value

=head2 decodeDate

Decodes date value from the string representation created using encodeDate(..) function.

param string representation of the date value
return original date value in unix time format (with microseconds)

=cut

