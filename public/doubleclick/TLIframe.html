<html>
<head>
</head>
<body>
<!-- for Tripelift integration: this should be located at hostname.com/doubleclick/TLIframe.html -->
<script type="text/javascript">

	function loadIFrameScript() {
		try {
			var searchString = document.location.search.substr(1);
			var parameters = searchString.split('&');
            var TLSrc = false;
            var TLDomain = "//ib.3lift.com/";
            var scriptSrc, scriptSrcURL, targetIframeSrc;
			for(var i = 0; i < parameters.length; i++) {
				var keyValuePair = parameters[i].split('=');
				var parameterName = keyValuePair[0];
				var parameterValue = keyValuePair[1];
				if(parameterName == "script_src") {
					scriptSrc = decodeURIComponent(parameterValue);
                    scriptSrcURL = (scriptSrc.indexOf("https:")!=-1) ? scriptSrc.split("https:")[1] : scriptSrc.split("http:")[1];
                    if (scriptSrcURL.indexOf(TLDomain)==0) TLSrc = true;
                    scriptSrc = TLDomain + scriptSrcURL.substr(TLDomain.length,scriptSrcURL.length);
                }
                else if (parameterName === "docsrc") {
                    targetIframeSrc = decodeURIComponent(parameterValue);
                }
			}
			generateScriptBlock(TLSrc,scriptSrc,targetIframeSrc);
		}
		catch(e) {
			fireError(e.message);
		}
	};

    function findTargetIframe (src) {
        var iframes = top.document.body.getElementsByTagName('IFRAME');
        var i = 0,
            ii = iframes.length
        ;
        var frame;
        for (; i<ii; i++) {
            frame = iframes[i];
            if (frame.src === src) {
                return frame;
            }
        }
        throw new Error('could not find ad frame with src: '+src);
    };

    function fireError(e) {
        var pix = document.createElement('IMG');
        pix.width = 0;
        pix.height = 0;
        pix.style.display = "none";
        pix.src = "//eb.3lift.com/sce?block=iframe_buster&inv_code="+encodeURIComponent(document.URL)+"&e="+encodeURIComponent(e);
        document.body.appendChild(pix);
    };
	
	function generateScriptBlock(TLSrc, scriptSrc,targetIframeSrc) {
	    if (TLSrc){
            var elementToBeReplaced;
            try {
                elementToBeReplaced = findTargetIframe(targetIframeSrc);
            }
            catch (e) {
                fireError(e.message);
                return; 
            }
    		elementToBeReplaced.style.display = 'none';
    		elementToBeReplaced.style.visibility = 'hidden';
    		elementToBeReplaced.style.width = "0px";
    		elementToBeReplaced.style.height = "0px";
            var script = window.top.document.createElement('script');
    		script.src = scriptSrc;
    		elementToBeReplaced.parentNode.insertBefore(script,elementToBeReplaced);	
        }	
	}
	
	loadIFrameScript();
	
</script>
</body>
</html>
