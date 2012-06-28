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
	}
	
	var jsdata,d=document,jss = window.quorum;
	
	if ( typeof jss.timeout != undefined && new Date().getTime() - jss.start.getTime() > jss.timeout ) {
		if (!jss.timedout) {
			jss.timedout = true;
      fullQuorum = false;
			jss.timeout_callback();
		}
	} else {
		for ( i in jss.libraries ) {
			jsdata = jss.libraries[i];
			if ( !jsdata.loaded ) {
				fullQuorum = false; //naturaly since we have not loaded all
				jsdata.status = false;
        //check to similar to status
				if ( typeof jsdata.require == 'undefined' || !jsdata.require || typeof window[jsdata.require] != 'undefined' ) {
					jsdata.loaded = true;
					if ( d.getElementById( jsdata.id ) == undefined) {
						var js = d.createElement('script');
						js.id = jsdata.id; js.async = true; js.type = 'text/javascript';
						js.src = jsdata['uri'];
						d.getElementsByTagName('head')[0].appendChild(js);
					}
				} else {
          //console.log(jsdata.id + ' waiting for ' + jsdata.require);
        }
			} else {
				if (!jsdata.status) {
          if (typeof jsdata.quorumx == 'string') {
            //
            jsdata.status = (typeof window[jsdata.quorumx] != 'undefined' || typeof jsdata.quorumx == 'object');  
          } else if (typeof jsdata.quorumx == 'function') {
            jsdata.status = jsdata.quorumx;
          }
          if (jsdata.status) {
            console.log( jsdata.id + ":" + jsdata.status );
            typeof jsdata.callback != 'undefined' && jsdata.callback( jsdata.id, window[jsdata.quorumx] );
          } else {
          	fullQuorum  = false;
          }
				}
			}
		}
	}
	if (!fullQuorum) {
		setTimeout(asyncjs,250);
	} else {
    if (!jss.timedout) {
      jss.full_quorum_callback();
    }
	}
}