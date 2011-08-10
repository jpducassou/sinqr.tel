/////////////////// Fixed values /////////////////////////////////////////////////////

function getPublicQueueURI() {
    return 'https://queue.amazonaws.com/041722291456/sinqrtel_public';
}

function getPublicId() {
    return 'AKIAIC2DBRTIUKHMGASQ';
}

function getPublicAccessKey() {
    return '2Ofh3ICjeKpxeWBV2KGmKJ4co4WoeGtpumiiGEPX';
}

/////////////////// Auth /////////////////////////////////////////////////////
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

//function ignoreCaseSort(a, b) {
//    var ret = 0;
//    a = a.toLowerCase();
//    b = b.toLowerCase();
//    if(a > b) ret = 1;
//    if(a < b) ret = -1;
//    return ret;
//}

function generateV1Signature(url, key) {
        var stringToSign = getStringToSign(url);
        //rstr2b64(rstr_hmac_sha1(str2rstr_utf8(k), str2rstr_utf8(d))); }
        var signed = Crypto.util.bytesToBase64( Crypto.HMAC (Crypto.SHA1, Crypto.charenc.UTF8.stringToBytes( stringToSign ), Crypto.charenc.UTF8.stringToBytes( key ), {asBytes: true}));
        alert( signed );
        return signed;
}

/////////////////// String To Sign /////////////////////////////////////////////////////
function getStringToSign(url) {

    var stringToSign = "";
    var query = url.split("?")[1];

    var params = query.split("&");
    //params.sort(ignoreCaseSort);
    for (var i = 0; i < params.length; i++) {
        var param = params[i].split("=");
        var name =   param[0];
        var value =  param[1];
        if (name == 'Signature' || undefined  == value) continue;
            stringToSign += name;
            stringToSign += decodeURIComponent(value);
         }

    return stringToSign;
}

/////////////////// Signed URL /////////////////////////////////////////////////////
function generateSignedURL(actionName, messageBody, queueUrl, accessKeyId, secretKey, endpoint, version) {
   //var url = endpoint + "?SignatureVersion=1&Action=" + actionName + "&Version=" + encodeURIComponent(version);
   var url = "SignatureVersion=1&Action=" + actionName + "&Version=" + encodeURIComponent(version);
   url += "&QueueUrl=" + encodeURIComponent( queueUrl );
   url += "&MessageBody=" + encodeURIComponent( messageBody );
   url += "&Timestamp=" + encodeURIComponent( getNowTimeStamp() );
   url += "&AWSAccessKeyId=" + encodeURIComponent(accessKeyId);
   url += "&Signature=" + encodeURIComponent( generateV1Signature( endpoint + "?" + url, secretKey) );

   return url;
}

function invokeRequest() {
            var messageBody = document.getElementById("MessageBody");
            var accessKeyId =  getPublicId();
            var secretKey =  getPublicAccessKey();
            var url = generateSignedURL("SendMessage", messageBody.value, getPublicQueueURI(), accessKeyId, secretKey, "https://queue.amazonaws.com", "2009-02-01");
		  var http = new XMLHttpRequest();

		  http.open("POST", getPublicQueueURI(), true);
		  //Send the proper header information along with the request
		  http.setRequestHeader("Content-type", "application/x-www-form-urlencoded;");
		  //http.setRequestHeader("Content-length", url.length);
		  http.setRequestHeader("Connection", "close" );

		  alert( url );
		  http.send( url );

		  http.onreadystatechange = function() {//Call a function when the state changes.
			if(http.readyState == 4 && http.status == 200) {
			  alert(http.responseText);
			} else {
			  alert("Readystate=" + http.readyState + " Status=" + http.status);
			}
		  }

        }

//        function displayUrl() {
//            var form = document.getElementById("UIForm");
//            var accessKeyId =  getPublicId();
//            var secretKey =  getPublicAccessKey();
//				var queueUrl = getPublicQueueURI();
//				form['QueueUrl'].value = "";
//				form.action = queueUrl;
//            var url = generateSignedURL("SendMessage",form, accessKeyId, secretKey, "https://queue.amazonaws.com", "2009-02-01");
//            document.getElementById("preview").innerHTML = "<b>Signed URL:</b><p/>" + url + "<p/>";
//            document.getElementById("preview").style.display = "block";
//        }
//
//        function displayStringToSign() {
//            var form = document.getElementById("UIForm");
//            var accessKeyId =  getPublicId();
//            var secretKey =  getPublicAccessKey();
//				var queueUrl = getPublicQueueURI();
//				form['QueueUrl'].value = "";
//				form.action = queueUrl;
//            var url = generateSignedURL("SendMessage",form, accessKeyId, secretKey, "https://queue.amazonaws.com", "2009-02-01");
//            var stringToSign = getStringToSign(url);
//            document.getElementById("preview").innerHTML = "<b>String To Sign:</b><p/>" + stringToSign + "<p/>";
//            document.getElementById("preview").style.display = "block";
//        }
