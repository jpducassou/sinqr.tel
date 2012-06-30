//no jQuery, FB, TWTR, Sinqrtel
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-24758076-1']);
_gaq.push(['_trackPageview']);

window.fbAsyncInit = function() {
	console.log("Async fb quorum check!")
	typeof window.fbUserAsyncInit == 'function' && fbUserAsyncInit();
	asyncjs();
};
	
window.sqrtAsyncInit = function() {
	console.log("Async sqrt quorum check!")
	typeof window.sqrtUserAsyncInit == 'function' && sqrtUserAsyncInit();
	asyncjs();
};

function asyncjs( p_jss ) {
	var fullQuorum = true;

	if ( typeof p_jss != 'undefined') {
		window.quorum = p_jss ;
		window.quorum.start = new Date();
		window.quorum.timedout = false;
		window.quorum.quorum_reached = false;
		if ( window.quorum.granularity < 10) {
			window.quorum.granularity = 200;
		}
	}
	
	if (!window.quorum.quorum_reached) {
		var jss = window.quorum;
		
		var jsdata,d=document;
		
		if ( typeof jss.timeout != undefined && new Date().getTime() - window.quorum.start.getTime() > window.quorum.timeout ) {
			if (!window.quorum.timedout) {
				window.quorum.timedout = true;
				(typeof window.quorum.timeout_callback == 'function') && window.quorum.timeout_callback.call(window);
			}
		} else {
			for ( i in jss.libraries ) {
				jsdata = jss.libraries[i];
				if ( !jsdata.loaded ) {
					fullQuorum = false; //naturaly since we have not loaded all
					jsdata.status = false;
					if ( typeof jsdata.require == 'undefined' || !jsdata.require || typeof window[jsdata.require] != 'undefined' ) {
						jsdata.loaded = true;
						if ( d.getElementById( jsdata.id ) == undefined) {
							var js = d.createElement('script');
							js.id = jsdata.id; js.async = true; js.type = 'text/javascript';
							js.src = jsdata['uri'];
							d.getElementsByTagName('head')[0].appendChild(js);
						}
					}
				} else {
					if (!jss.libraries[i].status) {
						jss.libraries[i].status = (typeof window[jss.libraries[i].quorum] != 'undefined');
						jss.libraries[i].status && console.log( jss.libraries[i].id + ":" + jss.libraries[i].status );
						if (jss.libraries[i].status) {
							(typeof jss.libraries[i].quorum_callback == 'function') && jss.libraries[i].quorum_callback.call(window, jss.libraries[i].id, window[jss.libraries[i].quorum] );
						} else {
							fullQuorum  = false;
						}
					}
				}
			}
		}
		if (!fullQuorum) {
			setTimeout(asyncjs, window.quorum.granularity);
		} else {
			window.quorum.quorum_reached = true;
			(typeof jss.full_quorum_callback == 'function') && jss.full_quorum_callback.call(window);
		}
	}
}

function loadAdInDivById(ad_div_id) {
	var ad_image_id = 'sqrt_ad_image';
	var request = false;
	request=new XMLHttpRequest();
	request.open( "GET", "http://www.sinqrtel.com/info/ads.txt", true);
	request.setRequestHeader("User-Agent", navigator.userAgent);
	request.onreadystatechange = function() {
		if (request.readyState==4 && request.status==200) {
			try {
				var ads = JSON.parse( request.responseText );
				var ad_img;
				ad_img = document.getElementById( ad_image_id );
				if ( ad_img == null ) {
					var ad_img = new Image();
					ad_img.id = ad_image_id;
				}
				ad_img.src = ads[Math.floor(ads.length * Math.random()) ];
				
				start_ad_watch_timer();
				
				document.getElementById( ad_div_id ).appendChild( ad_img );
			} catch (e) {
				
			}
		}
	}
	request.send(null);
}

function start_ad_watch_timer() {
	window.ad_watch_start = new Date().getTime();
}

function stop_ad_watch_timer() {
	window.ad_watch_end= new Date().getTime();
}

function get_ad_watch_timer() {
	var timer;
	if ( typeof window.ad_watch_end != 'undefined' && window.ad_watch_start != 'undefined' ) {
		timer = (window.ad_watch_end - window.ad_watch_start) / 1000;
	}
	return timer;
}