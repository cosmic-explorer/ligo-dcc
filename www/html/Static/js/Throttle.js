/**
## ******************************************************
##
## Name: Throttle.js
##
## Class attributes for <div id='throttle'></div>
##
## Example:
##          <div id='throttle'>
##             <tt>div class throttle JS error!</tt>
##             <p>
##             <script>
##                makeThrottleWidget('throttle')
##             </script>
##          </div>
##
## Phil Ehrens <pehrens@ligo.caltech.edu>
##
## August 19, 2010
##
## ******************************************************
**/

function makeThrottleWidget(e) {
   if (document.getElementById(e)) {
      var maxnum = getURLparm('maxdocs');
      if (maxnum == "") { maxnum = HOME_MAX_DOCS }
      var widget  = '<font color=red>Maximum documents returned: </font>';
          widget += '<input type=text name=maxdocs value='+maxnum+' size=3>\n<p>';
      var throttle = document.getElementById(e);
      throttle.innerHTML = widget;
   }
}

// I just ripped this from the net.
function getURLparm(name) {
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp(regexS);
  var results = regex.exec(window.location.href);
  if(results == null) {
    return "";
  } else {
    return results[1];
  }
}

