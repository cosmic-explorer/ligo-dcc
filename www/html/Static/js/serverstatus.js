/*
 * serverstatus.js
 *
 * A very simple to use client-side polling AJAX library to
 * keep users of your web services from being surprised when
 * they submit a request and discover that your service is
 * in maintenance mode.
 *
 * I recommend that you present a warning for one hour in
 * advance of a status change, or users could wind up being
 * just as surprised when the service suddenly announces it
 * is offline.
 *
 * To use, simply source this file and define serverStatusUrl
 * in the head of your document. Then activate using:
 *
 *   <body onLoad="startServerStatus('60000');">.
 *
 * Where 60000 in the example is the number of milliseconds
 * between polls of the cgi script.
 *
 * Your message can be in a static file, as in the example
 * below, or can be dynamically generated.
 *
 * The status message will be displayed in the div with the
 * id "serverstatus". When the message is empty the div will
 * not appear. Use css to style. The polling routine will
 * not be started if no div with the id "serverstatus" exists.
 *
 * Usage Example:
 *
 * <html>   
 *    <head>
 *       <script src="./js/serverstatus.js"></script>
 *       <script>
 *          // cgi script that returns status message
 *          var serverStatusUrl = "/cgi-bin/serverstatus.sh";
 *       </script>
 *    </head>
 *    <body onLoad="startServerStatus('60000');">
 *       <div id=serverstatus></div>
 *      ...
 *
 * example serverstatus.sh:
 *
 *    #!/bin/ksh
 *    #
 *    # The status page could just as easily come from an
 *    # inline command as from a hand edited file.
 *    #
 *    html=`cat /var/www/cgi-bin/serverstatus.html`
 *
 *    print "Content-Type: text/html
 *
 *    $html"
 *
 * Phil Ehrens <pehrens@ligo.caltech.edu>
 *
*/

var serverstatusIntervalID = 0;

// This is a minimal AJAX asynchronous request
function getServerStatus() {
   var xmlHttpReq = false;
   var self = this;
   // Firefox/Safari
   if (window.XMLHttpRequest) {
      self.xmlHttpReq = new XMLHttpRequest();
   }
   // IE
   else if (window.ActiveXObject) {
      self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
   }
   self.xmlHttpReq.open('GET', serverStatusUrl, true);
   self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
   self.xmlHttpReq.onreadystatechange = function() {
       if (self.xmlHttpReq.readyState == 4) {
          if (self.xmlHttpReq.responseURL.includes('login/index.shtml')) {
             // if server status is redirected to the disco url, the session expired
             // reload the whole page to force the logout and maintain the return url 
             document.location.reload();
          } else {
             updatepage(self.xmlHttpReq.responseText);
          }
       }
   }
   // The string "ping" here is entirely gratuitous
   self.xmlHttpReq.send("ping");
}

// This is the callback that writes the div contents
function updatepage(txt){
   if (txt.match(/^<meta/)) { txt = ''; }
   var el = document.getElementById("serverstatus");
   el.innerHTML = txt;
   if (txt.length > 32) {
      el.style.paddingTop    = '1.5em'; 
      el.style.paddingBottom = '0.5em';
      el.style.marginBottom  = '0.5em';
      el.style.marginTop     = '0.5em';
      el.style.border        = 'solid 5px white';
   } else {
      el.style.paddingTop    = '0.0em';
      el.style.paddingBottom = '0.0em';
      el.style.marginBottom  = '0.0em';
      el.style.marginTop     = '0.0em';
      el.style.border        = 'none';
   }
}

// Start the polling loop, but only if the div exists.
// If no div with the id "serverstatus" exists, this
// js utility is a no-op.
function startServerStatus(interval) {
   if (document.getElementById("serverstatus") !== null) {
      if ((typeof interval !== 'number') || (interval < 10000)) {
         interval = 10000;
      }
      getServerStatus();
      if (serverstatusIntervalID > 0) {
         clearInterval(serverstatusIntervalID);
      }
      serverstatusIntervalID = setInterval('getServerStatus()', interval);
   }
}
