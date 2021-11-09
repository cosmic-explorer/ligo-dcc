///////////////////////////////////////
/// Create a browser-specific message:
///////////////////////////////////////

var n = 0;
var b_name = '';	// Customize message for Chrome vs Opera

function instructions(n) {
	var msg = "<strong>NOTE:</strong> If using <strong>";

	var msg_end = "<br>This will also prevent double login on other sites ";
	msg_end += "that use LIGO.ORG accounts ";
	msg_end += "\(those with <em>albert.einstein</em> in the login prompt\).<br>";

	switch(n) {
		case 1:	// Chrome, Opera		
			msg += b_name;
			msg += " on Windows</strong>, ";
			msg += "you may be asked to login twice. ";
			msg += "To avoid this:<br>";
			msg += "<hr>";
			msg += "1. Right-click on your desktop shortcut to "
			msg += b_name;
			msg += ", then click Properties<br>";
			msg += "2. In the Target field after ";
			if (b_name == "Chrome") {
				msg += "&quot;chrome.exe&quot;";
			} else {
				msg += "&quot;&hellip;Opera/launcher.exe&quot;";
			}
			msg += ", add<br>";
			msg += "<pre style='font-size: 1.3em;text-align: center;'>--auth-schemes=\"basic,digest,ntlm\"</pre>";
			msg += "3. Click Apply<br>";
			msg += "4. Restart ";
			msg += b_name;
			msg += "<br><br>";
			msg += "<a href=\"../double-login/";
			if (b_name == "Chrome") {
				msg += "chrome.shtml\"";
			} else {
				msg += "opera.shtml\"";
			}
			msg += " style='color:#000;' target=_blank>Show me how</a><br>";
			msg += msg_end;
			break;
		case 2: // IE
			msg += b_name;
			msg += " on Windows</strong>, "; 
			msg += "you may be asked to login twice. ";
			msg += "To avoid this:<br>";
			msg += "<hr>";
			msg += "1. Click Tools (or press Alt+X), then Internet Options<br>";
			msg += "2. Click Advanced<br>";
			msg += "3. Under Security, find \"Enable Integrated Windows Authentication\" box. ";
			msg += "If it is checked, uncheck it.<br>";
			msg += "4. Click OK and restart IE.<br><br>";
			msg += "<a href=\"../double-login/ie.shtml\" style='color:#000;' target=_blank>Show me how</a><br>";
			msg += msg_end;
			break;
		case 3: // other
			msg += " browsers other than Chrome, Opera, or Internet Explorer</strong> ";
			msg += "(e.g., Maxthon, Lunascape) on Windows:<br><br>";
			msg += "If you are asked to login twice, please ";
			msg += "<a href=\"mailto:dcc-help@ligo.org\" style='color:#000;'>contact DCC help</a> ";
			msg += "for assistance.";
			break;
		default:
			msg = "No instructions for this browser.";
			break;
	}
	document.getElementById("myMessage").innerHTML = msg;
}



////////////////////////////////////
/// Check OS and browser/userAgent:
////////////////////////////////////

function isIE() {
	if (navigator.userAgent.indexOf('MSIE') !== -1 || navigator.appVersion.indexOf('Trident/') > 0) {
		return true;
	}
}


function DoubleAuthentication() {
	var os = navigator.platform;
	var browser = navigator.appName;
	if (typeof console !== 'undefined') { console.log(os+' '+browser); }
	if (os.match(/Win/)) {
		if (navigator.userAgent.match(/Maxthon/)) {
			instructions(3);
			return true;
		} else if ((navigator.userAgent.match(/Chrome/)) && !(navigator.userAgent.match(/OPR/))) {
			b_name = "Chrome";
			instructions(1);
			return true;
		} else if ((navigator.userAgent.match(/Opera/)) || (navigator.userAgent.match(/OPR/))) {
			b_name = "Opera";
			instructions(1);
			return true;
		//} else if (browser.match(/Explorer/)) {
		} else if (isIE() == true && !(navigator.userAgent.match(/Lunascape/))) {
			b_name = "Internet Explorer";
			instructions(2);
			return true;
		} else if (!(navigator.userAgent.match(/Firefox/)) && !(navigator.userAgent.match(/Safari/)) && !(navigator.userAgent.match(/Opera/))) {	// Lunascape etc 
			instructions(3);
			return true;
		} else {
			return false;
		}
	}
	//return false;
}



//////////////////////
/// Cookie functions: 
//////////////////////

var noAlert = getCookie("noAlert");   // keep it global

function getCookie(c_name) {
        var c_value = document.cookie;
        var c_start = c_value.indexOf(" " + c_name + "=");
        if (c_start == -1) {
                c_start = c_value.indexOf(c_name + "=");
        }
        if (c_start == -1) {
                c_value = null;
        } else {
                c_start = c_value.indexOf("=", c_start) + 1;
                var c_end = c_value.indexOf(";", c_start);
                if (c_end == -1) {
                        c_end = c_value.length;
                }
                c_value = unescape(c_value.substring(c_start,c_end));
        }
        return c_value;
}

function setCookie(c_name,value,exdays) {
        var exdate = new Date();
        var exdays = 3650;
        exdate.setDate(exdate.getDate() + exdays);
        var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
        document.cookie = c_name + "=" + c_value;
}

function checkCookie() {
        var noAlert=getCookie("noAlert");
        if (noAlert!=null && noAlert!="") {
               document.getElementById('infobox').style.display='none'; // hide the workaround div
               return true;
        } else {
		return false;
	}
}



////////////////////////////////////////////////////
/// Master function that gets called in index.html:
////////////////////////////////////////////////////

function showBox() {
	if (DoubleAuthentication() == true) {
		var head = document.getElementsByTagName('head')[0];
		var myscripts = ["./js/show-msg.js","./js/checkbox.js"];
		for (var i=0; i<myscripts.length; i++) {
			var script  = document.createElement('script');
			script.type = 'text/javascript';
			script.src = './' + myscripts[i];
			head.appendChild(script);
		}

		if (checkCookie() == false) {
			document.getElementById("infobox").style.visibility = "visible";
		}
	} 
}

