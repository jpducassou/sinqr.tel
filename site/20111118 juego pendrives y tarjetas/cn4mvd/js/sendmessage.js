/////////////////// Fixed values /////////////////////////////////////////////////////

function getPublicQueueURI() {
  return 'https://queue.amazonaws.com/041722291456/sinqrtel_pendrives';
}

function getPublicId() {
  return 'AKIAIC2DBRTIUKHMGASQ';
}

function getPublicAccessKey() {
  return '2Ofh3ICjeKpxeWBV2KGmKJ4co4WoeGtpumiiGEPX';
}

function setCookie(c_name,value,exdays)
{
var exdate=new Date();
exdate.setDate(exdate.getDate() + exdays);
var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
document.cookie=c_name + "=" + c_value;
}

function getCookie(c_name)
{
var i,x,y,ARRcookies=document.cookie.split(";");
for (i=0;i<ARRcookies.length;i++)
{
  x=ARRcookies[i].substr(0,ARRcookies[i].indexOf("="));
  y=ARRcookies[i].substr(ARRcookies[i].indexOf("=")+1);
  x=x.replace(/^\s+|\s+$/g,"");
  if (x==c_name)
    {
    return unescape(y);
    }
  }
}

/////////////////// Auth /////////////////////////////////////////////////////

function addZero(n) {
    return ( n < 0 || n > 9 ? "" : "0" ) + n;
}

Date.prototype.toISODate =
  new Function("with (this)\n    return " +
    "getFullYear()+'-'+addZero(getMonth()+1)+'-'" +
    "+addZero(getDate())+'T'+addZero(getHours())+':'" +
    "+addZero(getMinutes())+':'+addZero(getSeconds())+'.000Z'");

function getNowTimeStamp() {
    var time = new Date();
    var gmtTime = new Date(time.getTime() + (time.getTimezoneOffset() * 60000));

    return gmtTime.toISODate() ;
}

function ignoreCaseSort(a, b) {
  var ret = 0;
  a = a.toLowerCase();
  b = b.toLowerCase();
  if(a > b) ret = 1;
  if(a < b) ret = -1;
  return ret;
}

/////////////////// String To Sign /////////////////////////////////////////////////////
function getStringToSign( params ) {
  var stringToSign = "";

  var fields = params.split("&");
  fields.sort(ignoreCaseSort);
  for (var i = 0; i < fields.length; i++) {
    var param = fields[i].split("=");
    var name =  param[0];
    var value = param[1];
    //Parameters that should be skipped... but we should see none...
    if (name == 'Signature' || undefined  == value) continue;
    stringToSign += name;
    stringToSign += decodeURIComponent(value);
  }

  return stringToSign;
}

/////////////////// Signed URL /////////////////////////////////////////////////////
function generateSignedParams(actionName, messageBody, queueUrl, accessKeyId, secretKey, endpoint, version) {
  //signable parameters
  var params = "SignatureVersion=1&Action=" + actionName + "&Version=" + encodeURIComponent(version);
  params += "&QueueUrl=" + encodeURIComponent( queueUrl );
  params += "&MessageBody=" + encodeURIComponent( messageBody );
  params += "&Timestamp=" + encodeURIComponent( getNowTimeStamp() );
  params += "&AWSAccessKeyId=" + encodeURIComponent(accessKeyId);

  //calculate V1 signature with signable parameters
  var stringToSign = getStringToSign( params );
  var signature = Crypto.util.bytesToBase64( Crypto.HMAC (Crypto.SHA1, Crypto.charenc.UTF8.stringToBytes( stringToSign ), Crypto.charenc.UTF8.stringToBytes( secretKey ), {asBytes: true}));

  //parameters that should not be signed
  params += "&Signature=" + encodeURIComponent( signature );
  return params;
}

function invokeRequest(message) {
  var postBody = generateSignedParams("SendMessage", message, getPublicQueueURI(), getPublicId(), getPublicAccessKey(), "https://queue.amazonaws.com", "2009-02-01");
  //request creation
  var http = new XMLHttpRequest();
  http.open("POST", getPublicQueueURI(), true);
  http.setRequestHeader("Content-type", "application/x-www-form-urlencoded;"); //Send the proper header information along with the request
  //request length can be skipped... so do it
  //http.setRequestHeader("Content-length", url.length);
  http.setRequestHeader("Connection", "close" );

  http.send( postBody );

  /*http.onreadystatechange = function() {//Call a function when the state changes.
    if(http.readyState == 4 && http.status == 200) {
    }
  }*/
}
