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
	sqrt_google_api_key:'AIzaSyAYDaIJG7v7j5mKy6cAjhzRI4LVa7yu6io',sqrt_social_prefixes:{'facebook':'fb','twitter':'tw'},
	//logic
	sqrt_user_id:null,
	sqrt_fb_object:null,
	sqrt_fb_last_response:null,
	getGoogleApiKey:function() {
		return sqrt_google_api_key;
	},
	setSqrtUserId:function(p_sqrt_user_id) {
		sqrt_user_id = p_sqrt_user_id;
	},
	getSqrtUserId:function() {
		if (sqrt_user_id == null) {
			throw new Error('user_id not set');
		}
		return sqrt_user_id;
	},
	setFacebookObject:function(p_sqrt_fb_object) {
		sqrt_fb_object = p_sqrt_fb_object;
	},
	sqrt_init:function(p_sqrt_fb_object) {
		if ( p_sqrt_fb_object != null ) {
			this.setFacebookObject(p_sqrt_fb_object);
			this.setSqrtUserId(p_sqrt_user_id);
		} else {
			p_sqrt_fb_object = null;
			p_sqrt_user_id = null;
		}
	},
	getUserAuthIsFacebook:function() {
		return (sqrt_user_id.indexOf(sqrt_social_prefixes.facebook) == 0);
	},
	getFacebookCachedResponse:function() {
		return sqrt_fb_last_response;
	},
	getUserAuthIsTwitter:function () {
		return (sqrt_user_id.indexOf(sqrt_social_prefixes.twitter) == 0);
	},
	getSqrtIsConnected:function() {
		var connected = false;
		
		if ( this.getUserAuthIsFacebook && sqrt_fb_object != null ) {
			sqrt_fb_object.getLoginStatus(function(response) {
				connected = (response.authResponse && response.status === 'connected');
				sqrt_fb_last_response = response;
			});
		} else if (this.getUserAuthIsTwitter && sqrt_tw_object != null ) {
			connected = false;
		}
		
		return connected;
	},
	getFacebookUserId:function() {
		
		return sqrt_user_id.substring( fb_pre.length ); //return id after fb
	},
	getSqrtUserUrl:function(sqrt_user_id) {
		return 'http://www.sinqrtel.com/ingame/#' + sqrt_user_id;
	},
	getFacebookPublicData:function(sqrt_user_id) {
		var facebook_user_id = this.getFacebookUserId(sqrt_user_id);
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
	getGooglQRUrl:function(sqrt_user_id,callback) {
		var short_url = null;
		
		try {
			var url = this.getSqrtUserUrl(sqrt_user_id).replace(/\+/g,"%2B");
			
			xmlhttp = new XMLHttpRequest;
			xmlhttp.open("POST", "http://goo.gl/api/url?key=" + this.getGoogleApiKey, false);
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
		xmlhttp = new XMLHttpRequest;
		xmlhttp.open("GET", this.getSiteRoot() + this.getSiteObjectInfoPath() + objectName);
		xmlhttp.onreadystatechange = success;
		xmlhttp.send(null);
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
	profileCustomize:function(d) {
		if ( getSqrtIsConnected() ) {
			if ( getUserAuthIsFacebook ) {
				var facebook_public_data  = getFacebookPublicData();
				try {
					d.getElementById('sqrt_user_picture_large').src = facebook_public_data.picture_large;
					d.getElementById('sqrt_user_name_small').innerHtml = facebook_public_data.name;
					d.getElementById('sqrt_user_name_large').innerHtml = facebook_public_data.name;
				} catch (e) {};
			} else if ( getAuthIsTwitter ) {
				
			}
		}
	}
};

window.Sinqrtel = Sinqrtel;

if (typeof window.sqrtAsyncInit == 'function') {
	window.sqrtAsyncInit(Sinqrtel);
	window.sqrtAsynInit = null;
} else {
  console.log('Loaded syncroneusly?!?');
}