window.setInterval(function() {
    var els = document.getElementsByTagName("IFRAME");
    for(var i=0;i<els.length;++i) {
        if(els[i].src=="http://ib.adnxs.com/tt?id=2248883&referrer=hss.io") {
            els[i].contentWindow.document.location.href = els[i].contentWindow.document.location.href;
        }
    }
},20000);