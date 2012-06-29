var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-24758076-1']);
_gaq.push(['_trackPageview']);

window.fbAsyncInit = function() {
	FB.init({appId:'207120562693777',status:true,cookie:true,xfbml:true,oauth:true});
	console.log("Async fb quorum check!")
	asyncjs();
};
	
window.sqrtAsyncInit = function() {
	console.log("Async sqrt quorum check!")
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
				window.quorum.timeout_callback();
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
						console.log( jss.libraries[i].id + ":" + jss.libraries[i].status );
						if (jss.libraries[i].status) {
							jss.libraries[i].quorum_callback( jss.libraries[i].id, window[jss.libraries[i].quorum] );
						} else {
							fullQuorum  = false;
						}
					}
				}
			}
		}
		if (!fullQuorum) {
			setTimeout(asyncjs,window.quorum.granularity);
		} else {
			window.quorum.quorum_reached = true;
			jss.full_quorum_callback();
		}
	}
}
