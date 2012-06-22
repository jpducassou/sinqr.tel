//sqrt_basics
/*
Define setObject on localStorage
getObject = null if key not present instead of throwing Illegal access exception.
*/
Storage.prototype.setObject = function(key, value) {
  this.setItem(key, JSON.stringify(value));
};

Storage.prototype.getObject = function(key) {
	var value = this.getItem(key);
	if (value==undefined) {
		return value;
	} else {
		//ERROR on undefined: "return value && JSON.parse(value);"
		return JSON.parse(value);
	}
};

var Sinqrtel = {
	//configuration
	sqrt_google_api_key:'AIzaSyAYDaIJG7v7j5mKy6cAjhzRI4LVa7yu6io',
	sqrt_amazon_queue_uri:'https://queue.amazonaws.com/041722291456/sinqrtel_public',
	sqrt_amazon_id:'AKIAIC2DBRTIUKHMGASQ',
	sqrt_amazon_access_key:'2Ofh3ICjeKpxeWBV2KGmKJ4co4WoeGtpumiiGEPX',
	sqrt_amazon_endpoint:'https://queue.amazonaws.com',
	sqrt_amazon_version:'2009-02-01',
	//sqrt_social_prefixes:{'facebook':'fb','twitter':'tw'},
	//logic
	sqrt_user_id:null,
	sqrt_fb_status:null,
	sqrt_tw_status:null,
	sqrt_fb_last_response:null,
	getGoogleApiKey:function() {
		return this.sqrt_google_api_key;
	},
	setSqrtUserId:function(p_sqrt_user_id) {
		this.sqrt_user_id = p_sqrt_user_id;
	},
	getSqrtUserId:function() {
		return this.sqrt_user_id;
	},
	getFacebookStatus:function() {
		return this.sqrt_fb_status;
	},
	getTwitterStatus:function() {
		return this.sqrt_tw_status;
	},
	//runs in window context...
	sqrt_update_fb_status:function (response) {
		if (response != null && response.authResponse && response.status === 'connected') {
			Sinqrtel.sqrt_fb_status = true;
			Sinqrtel.setSqrtUserId( 'fb' + response.authResponse.userID );
			Sinqrtel.sqrt_profile_customize(window.document);
		} else {
			Sinqrtel.sqrt_fb_status = false;
			Sinqrtel.setSqrtUserId(null);
		}
		Sinqrtel.setFacebookCachedResponse(response);
	},
	sqrt_init:function() {
		console.log("sqrt_init");
		if ( typeof FB != "undefined" ) {
			FB.Event.subscribe('auth.statusChange', this.sqrt_update_fb_status );
			//FB.getLoginStatus( this.sqrt_update_fb_status );
		} else {
			this.sqrt_fb_connected = false;
			this.setSqrtUserId(null);
		}
	},
	getUserAuthIsFacebook:function() {
		return (this.getSqrtUserId().indexOf( 'fb' ) == 0);
	},
	getFacebookCachedResponse:function() {
		return this.sqrt_fb_last_response;
	},
	setFacebookCachedResponse:function(fb_last_response) {
		this.sqrt_fb_last_response = fb_last_response;
	},
	getUserAuthIsTwitter:function () {
		return (this.getSqrtUserId().indexOf( 'tw' ) == 0);
	},
	getSqrtIsConnected:function() {
		var connected = (this.getSqrtUserId() != null) && (
			( this.getUserAuthIsFacebook() && this.getFacebookStatus() ) ||
			( this.getUserAuthIsTwitter() && this.getTwitterStatus() )
		);
				
		return connected;
	},
	getFacebookUserId:function() {
		return this.getSqrtUserId().substring( 'fb'.length );
	},
	getSqrtUserUrl:function() {
		return 'http://www.sinqrtel.com/ingame/#' + this.getSqrtUserId();
	},
	getFacebookPublicData:function() {
		var facebook_user_id = this.getFacebookUserId();
		var facebook_public_data;
		try {
			xmlhttp = new XMLHttpRequest;
			xmlhttp.open("GET", "http://graph.facebook.com/" + facebook_user_id, false);
			xmlhttp.send(null);
			
			facebook_public_data = JSON.parse(xmlhttp.responseText);
			facebook_public_data.picture_large = 'http://graph.facebook.com/' + facebook_user_id  + '/picture?type=large' ;
			facebook_public_data.picture_small = 'http://graph.facebook.com/' + facebook_user_id  + '/picture?type=small' ;
		} catch (e) {
			facebook_public_data = null;
		}
		
		return facebook_public_data;
	},
	getGooglQRUrl:function(callback) {
		var short_url = null;
		
		try {
			var url = this.getSqrtUserUrl().replace(/\+/g,"%2B");
			
			xmlhttp = new XMLHttpRequest;
			xmlhttp.open("POST", "https://www.googleapis.com/urlshortener/v1/url?key=" + this.getGoogleApiKey(), false);
			xmlhttp.setRequestHeader('Content-Type','application/json');
			xmlhttp.send('{"longUrl":"' + url + '"}' );
			
			var googl = JSON.parse(xmlhttp.responseText);
			short_url = googl.id;
		} catch(e) {
			short_url = null
		}
		if (callback != null ) {
			callback(short_url);
		}
		return short_url;
	},
	getSiteRoot:function() {
    return "http://www.sinqrtel.com";
	},
	getSiteObjectInfoPath:function() {
    return "/objectinfo/";
	},
	getTimeStamp:function() {
		return Math.round((new Date()).getTime() / 1000 );
	},
	sumAndUpdateScoresToTimeStamp:function( scoreArray, timeStamp ) {
		var sum = 0;
		var scoreIterator = 0;
		while( scoreIterator < scoreArray.length ) {
			if ( scoreArray[scoreIterator][0] > timeStamp ) {
				sum+=scoreArray[scoreIterator][1];
				scoreIterator++;
			} else {
				//delete one, iterator should not be incremented
				scoreArray.splice(scoreIterator,1);
			}
		}
		return sum;
	},
	getObjectInfo:function( objectName, success ) {
		try {
			xmlhttp = new XMLHttpRequest;
			xmlhttp.open("GET", this.getSiteRoot() + this.getSiteObjectInfoPath() + objectName);
			xmlhttp.onreadystatechange = success;
			xmlhttp.send(null);
		} catch (e) {
			success(null,0);
		}
	},
	addLocalScore:function( scoreArray, score, timeStamp ) {
		scoreArray.push( [timeStamp, score] );
	},
	storeScore:function( scoreArray ) {
		localStorage.setObject( 'score', scoreArray );
	},
	//gets document and changes fixed elements
	//sqrt_user_picture_large (img)
	//sqrt_user_name_small (textNode)
	//sqrt_user_name_large (textNode)
	//sqrt_user_qr (img)
	sqrt_profile_customize:function(d) {
		console.log("sqrt_profile_customize");
		if ( this.getSqrtIsConnected() ) {
			console.log("sqrt_profile_customize, connected");
			//facebook login
			if ( this.getUserAuthIsFacebook ) {
				console.log("sqrt_profile_customize, connected, auth facebook");
				var facebook_public_data  = this.getFacebookPublicData();
				try {
					console.log("sqrt_profile_customize, connected, auth facebook, try main");
					d.getElementById('sqrt_user_picture_large').src = facebook_public_data.picture_large;
					d.getElementById('sqrt_user_name_small').textContent = facebook_public_data.name;
					d.getElementById('sqrt_user_name_large').textContent = facebook_public_data.name;
				} catch (e) {};
			} else if ( this.getAuthIsTwitter ) {
				
			}
			//all login methods
			try {
				console.log("sqrt_profile_customize, try qr");
				d.getElementById('sqrt_user_qr').src=this.getGooglQRUrl() + '.qr';
			} catch (e) {};
		}
	},
	sqs_send:function(message, stateChange) {
		function _addZero(n) {
				return ( n < 0 || n > 9 ? "" : "0" ) + n;
		}
		function _getNowTimeStamp() {
			var time = new Date();
			var gmtTime = new Date(time.getTime() + (time.getTimezoneOffset() * 60000));
			
			var d = [gmtTime.getFullYear(),gmtTime.getMonth()+1,gmtTime.getHours()];
			var t = [gmtTime.getHours(), gmtTime.getMinutes(), gmtTime.getSeconds()];
			
			return d.join('-') + 'T' + t.join(':') + '.000Z';
			
			return (function(d){
				return d.getFullYear()+'-'+_addZero()+'-'+_addZero(d.getDate())+'T'+_addZero(d.getHours())+':'+_addZero(d.getMinutes())+':'+_addZero(d.getSeconds())+ '.000Z';
			})(gmtTime);
		}
		function _ignoreCaseSort(a, b) {
			var ret = 0;
			a = a.toLowerCase();
			b = b.toLowerCase();
			if(a > b) ret = 1;
			if(a < b) ret = -1;
			return ret;
		}
		function _getStringToSign( params ) {
			var stringToSign = "";
			
			var fields = params.split("&");
			fields.sort(_ignoreCaseSort);
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
		function _generateSignedParams(actionName, messageBody, queueUrl, accessKeyId, secretKey, endpoint, version) {
			//signable parameters
			var params = "SignatureVersion=1&Action=" + actionName + "&Version=" + encodeURIComponent(version) +
			"&QueueUrl=" + encodeURIComponent( queueUrl ) + "&MessageBody=" + encodeURIComponent( messageBody ) +
			"&Timestamp=" + encodeURIComponent( getNowTimeStamp() ) + "&AWSAccessKeyId=" + encodeURIComponent(accessKeyId);
		
			//calculate V1 signature with signable parameters
			var stringToSign = _getStringToSign( params );
			var signature = Crypto.util.bytesToBase64( Crypto.HMAC (Crypto.SHA1, Crypto.charenc.UTF8.stringToBytes( stringToSign ), Crypto.charenc.UTF8.stringToBytes( secretKey ), {asBytes: true}));
		
			//parameters that should not be signed
			params += "&Signature=" + encodeURIComponent( signature );
			return params;
		}
		var postBody = _generateSignedParams( "SendMessage", message, Sinqrtel.sqrt_amazon_queue_uri, Sinqrtel.sqrt_amazon_id, Sinqrtel.sqrt_amazon_access_key, Sinqrtel.sqrt_amazon_endpoint, Sinqrtel.sqrt_amazon_version );
		//request creation
		var http = new XMLHttpRequest();
		http.open("POST", Sinqrtel.sqrt_amazon_queue_uri, true);
		http.setRequestHeader("Content-type", "application/x-www-form-urlencoded;"); //Send the proper header information along with the request
		//request length can be skipped... so do it
		//http.setRequestHeader("Content-length", url.length);
		http.setRequestHeader("Connection", "close" );
		http.onreadystatechange = stateChange;
		http.send( postBody );
	}
};

window.Sinqrtel = Sinqrtel;

if (typeof window.sqrtAsyncInit == 'function') {
	window.sqrtAsyncInit(Sinqrtel);
	window.sqrtAsyncInit = null;
} else {
  console.log('Loaded syncroneusly?!?');
}