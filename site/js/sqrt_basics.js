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
	}
};

window.Sinqrtel = Sinqrtel;

if (typeof window.sqrtAsyncInit == 'function') {
	window.sqrtAsyncInit(Sinqrtel);
	window.sqrtAsyncInit = null;
} else {
  console.log('Loaded syncroneusly?!?');
}