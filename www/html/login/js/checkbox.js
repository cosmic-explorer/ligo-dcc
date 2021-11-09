function checkBox() {
	var z = 0;
	if (document.getElementById("mybox").checked==true) {
		z = 1;
		getCookie("noAlert");
		setCookie("noAlert",noAlert,1);
	} else {
		z = 0;
	}
}

function uncheck() {
	document.getElementById("mybox").checked=false;
}

