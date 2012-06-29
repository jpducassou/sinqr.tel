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