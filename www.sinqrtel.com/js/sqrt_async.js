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
	if ( value == undefined ) value = null;
	try {
		value = JSON.parse(value);
	} catch (e) {
		value = null;
	}
	return returnValue;
};

window.onbeforeunload = function () {
	console.log = window.location.hash;
}

var Sinqrtel = {
	//configuration
	sqrt_google_api_key:'AIzaSyAYDaIJG7v7j5mKy6cAjhzRI4LVa7yu6io',
	sqrt_amazon_tag_queue_uri:'https://queue.amazonaws.com/041722291456/sinqrtel_public_tag',
	sqrt_amazon_error_queue_uri:'https://queue.amazonaws.com/041722291456/sinqrtel_public_error',
	sqrt_amazon_id:'AKIAIC2DBRTIUKHMGASQ',
	sqrt_amazon_access_key:'2Ofh3ICjeKpxeWBV2KGmKJ4co4WoeGtpumiiGEPX',
	sqrt_amazon_endpoint:'https://queue.amazonaws.com',
	sqrt_amazon_version:'2009-02-01',
	//sqrt_social_prefixes:{'facebook':'fb','twitter':'tw'},
	//logic
	sqrt_user_id:"",
	sqrt_initialized:false,
	sqrt_fb_status:false,
	sqrt_view_user_id:"",
	sqrt_tw_status:false,
	sqrt_fb_last_response:null,
	sqrt_score_array:new Array(),
	getGoogleApiKey:function() {
		return this.sqrt_google_api_key;
	},
	setVisitingUserId:function(view_user_id) {
		this.sqrt_view_user_id = view_user_id;
	},
	getVisitUserId:function() {
		return this.sqrt_view_user_id;
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
			Sinqrtel.setVisitingUserId( window.location.hash );
			var user_id = Sinqrtel.getVisiting()?Sinqrtel.getVisitUserId():Sinqrtel.getSqrtUserId();
			Sinqrtel.ProfileCustomize(window.document, user_id);
		} else {
			Sinqrtel.sqrt_fb_status = false;
			Sinqrtel.setSqrtUserId(null);
		}
		Sinqrtel.setFacebookCachedResponse(response);
		this.sqrt_initialized = true;
	},
	getVisiting:function() {
		return ( this.sqrt_user_id == "" || this.sqrt_user_id == null );
	},
	getViewUserId:function() {
		return this.getVisiting()?this.getVisitUserId():this.getSqrtUserId();
	},
	getSqrtInitialized:function() {
		return this.sqrt_initialized;
	},
	init:function() {
		console.log("sqrt_init");
		this.sqrt_initialized = false;
		
		if ( window.location.hash == "" || window.location.hash =="#myself" ) {
			if ( typeof FB != "undefined" ) {
				FB.Event.subscribe('auth.statusChange', this.sqrt_update_fb_status );
				FB.getLoginStatus( this.sqrt_update_fb_status );
			} else {
				this.sqrt_fb_connected = false;
			}	
		} else {
			//kill # and save as user
			this.setVisitingUserId(window.location.hash.substring(1));
			var user_id = this.getViewUserId();
			this.ProfileCustomize(window.document, user_id );
			this.sqrt_initialized = true;
		}
	},
	getUserAuthIsFacebook:function(sqrt_user_id) {
		return (sqrt_user_id.indexOf( 'fb' ) == 0);
	},
	getFacebookCachedResponse:function() {
		return this.sqrt_fb_last_response;
	},
	setFacebookCachedResponse:function(fb_last_response) {
		this.sqrt_fb_last_response = fb_last_response;
	},
	getUserAuthIsTwitter:function (sqrt_user_id) {
		return (sqrt_user_id.indexOf( 'tw' ) == 0);
	},
	getSqrtIsConnected:function() {
		var connected = (this.getSqrtUserId() != null) && (
			( this.getUserAuthIsFacebook(sqrt_user_id) && this.getFacebookStatus() ) ||
			( this.getUserAuthIsTwitter(sqrt_user_id) && this.getTwitterStatus() )
		);
				
		return connected;
	},
	getProviderUserId:function(sqrt_user_id) {
		//kill prefix
		return sqrt_user_id.substring( 'xx'.length );
	},
	getSqrtUserUrl:function(sqrt_user_id) {
		return 'http://www.sinqrtel.com/ingame/#' + sqrt_user_id;
	},
	getFacebookPublicData:function(sqrt_user_id) {
		//other user or logged in user
		var facebook_user_id = this.getProviderUserId(sqrt_user_id);
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
	getGooglQRUrl:function(sqrt_user_id, callback) {
		var short_url = null;
		
		try {
			var url = this.getSqrtUserUrl(sqrt_user_id).replace(/\+/g,"%2B");
			
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
	sumAndUpdateScoresToTimeStamp:function( timeStamp ) {
		//gets score and delete seen server scores to timeStamp
		var sum = 0;
		var scoreIterator = 0;
		while( scoreIterator < this.sqrt_score_array.length ) {
			if ( this.sqrt_score_array[scoreIterator][0] > timeStamp ) {
				sum+=this.sqrt_score_array[scoreIterator][1];
				scoreIterator++;
			} else {
				//delete one, iterator should not be incremented
				this.sqrt_score_array.splice(scoreIterator,1);
			}
		}
		return sum;
	},
	getObjectInfo:function( objectName, callback ) {
		var object_info = null;
		
		try {
			xmlhttp = new XMLHttpRequest;
			xmlhttp.open("GET", this.getSiteRoot() + this.getSiteObjectInfoPath() + objectName, false);
			xmlhttp.onreadystatechange = callback;
			xmlhttp.send(null);
			
			if ( xmlhttp.status == 200 ) {
				var object_info = JSON.parse(xmlhttp.responseText);
			}
		} catch(e) {}
		
		return object_info;
	},
	addLocalScore:function( score, timeStamp ) {
		this.sqrt_score_array.push( [timeStamp, score] );
	},
	storeScore:function( ) {
		localStorage.setObject( 'score', this.sqrt_score_array );
	},
	//gets document and changes fixed elements
	//sqrt_user_picture_large (img)
	//sqrt_user_name_small (textNode)
	//sqrt_user_name_large (textNode)
	//sqrt_user_qr (img)
	ProfileCustomize:function(d, sqrt_user_id) {
		console.log("sqrt_profile_customize");
		if ( sqrt_user_id != "" ) {
			console.log("sqrt_profile_customize, connected");
			//facebook login
			if ( this.getUserAuthIsFacebook(sqrt_user_id) ) {
				console.log("sqrt_profile_customize, connected, auth facebook");
				var facebook_public_data  = this.getFacebookPublicData(sqrt_user_id);
				try {
					console.log("sqrt_profile_customize, connected, auth facebook, try main");
					d.getElementById('sqrt_user_picture_large').src = facebook_public_data.picture_large;
					d.getElementById('sqrt_user_name_small').textContent = facebook_public_data.name;
					d.getElementById('sqrt_user_name_large').textContent = facebook_public_data.name;
				} catch (e) {};
			} else if ( this.getAuthIsTwitter(sqrt_user_id) ) {
				
			}
			//all login methods
			try {
				console.log("sqrt_profile_customize, try qr");
				d.getElementById('sqrt_user_qr').src=this.getGooglQRUrl(sqrt_user_id) + '.qr';
				var userInfo = this.getObjectInfo( sqrt_user_id );
				try {
					if ( userInfo == null ) {
						d.getElementById('sqrt_user_score_container').style.display = 'none';
					} else {
						d.getElementById('sqrt_user_score_container').style.display = 'block';
						d.getElementById('sqrt_user_score_server').textContent = userInfo.score;
						d.getElementById('sqrt_user_score_local').textContent = this.sumAndUpdateScoresToTimeStamp(userInfo.timestamp);
					}
				} catch (e) {
					//try to update just local score...
					d.getElementById('sqrt_user_score_local').textContent = this.sumAndUpdateScoresToTimeStamp(userInfo.timestamp);
				}
			} catch (e) {};
		}
	},
	SendServerMessage:function(message, error, stateChange ) {
		function _addZero(n) {
				return ( n < 0 || n > 9 ? "" : "0" ) + n;
		}
		function _getNowTimeStamp() {
			Number.prototype.dd = function () {
				with (this) return ( valueOf() < 0 || valueOf() > 9 ? "" : "0" ) + valueOf();
			}
			
			return (function(d) {
				with (d)
				return	[ getUTCFullYear().dd()	,(getUTCMonth()+1).dd()	,getUTCDate().dd()		].join('-') + 'T' +
								[ getUTCHours().dd()		, getUTCMinutes().dd()	,getUTCSeconds().dd()	].join(':') + '.000Z';
			})( new Date());
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
			var signature = CryptoJS.HmacSHA1(stringToSign, secretKey);
			
			//parameters that should not be signed
			params += "&Signature=" + encodeURIComponent( signature.toString(CryptoJS.enc.Base64));
			return params;
		}
		var queue_uri = error?this.sqrt_amazon_error_queue_uri:sqrt_amazon_tag_queue_uri;
		var postBody = _generateSignedParams( "SendMessage", message, queue_uri, Sinqrtel.sqrt_amazon_id, Sinqrtel.sqrt_amazon_access_key, Sinqrtel.sqrt_amazon_endpoint, Sinqrtel.sqrt_amazon_version );
		//request creation
		var http = new XMLHttpRequest();
		http.open("POST", queue_uri, true);
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
  console.log('Loaded syncroneously?!?');
}