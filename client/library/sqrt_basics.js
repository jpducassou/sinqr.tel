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

var sqrt = {
	getGoogleApiKey:function() {
		return 'AIzaSyAYDaIJG7v7j5mKy6cAjhzRI4LVa7yu6io';
	},
	getSqrtUserUrl:function(sqrt_user_id) {
		return 'http://www.sinqrtel.com/ingame/#fb' + sqrt_user_id;
	},
	getGooglQRUrl:function(sqrt_user_id) {
		var shorturl = null;
		
		try {
			var urlEscaped = escape(url).replace(/\+/g,"%2B");
			
			xmlhttp.open("POST", "http://goo.gl/api/url?user=gonzalo@computadorasyservice.com&url=" + getSqrtUserUrl(sqrt_user_id) + "&key=" + this.getGoogleApiKey, false);
			xmlhttp.send(null);
			
			var googl = JSON.parse(xmlhttp.responseText);
			shorturl = googl.id;
		} catch(e) {
			shorturl = null
		}
		return shorturl;
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
		$.getJSON( sqrt_getSiteRoot() + sqrt_getSiteObjectInfoPath() + objectName, success );
	},
	addLocalScore:function( scoreArray, score, timeStamp ) {
		scoreArray.push( [timeStamp, score] );
	},
	storeScore:function( scoreArray ) {
		localStorage.setObject( 'score', scoreArray );
	}
};

if (typeof window.sqrtAsyncInit == 'function') {
	window.sqrtAsyncInit(this);
} else {
  console.log('Loaded syncroneusly?!?');
}