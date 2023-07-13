/*
 * The ICS URL is made from the base, a customfield
 * which is 10032 for non-assemblies and 10250 for
 * assemblies.
 *
 * An example would be:
 *
 *  customfield_10250=d1234567
 *
 */

// Do we have the REQUIRED Prototype Library?
if (typeof(window.Prototype) == "undefined") {
   alert("The Prototype Javascript Library is REQUIRED.");
}

var ICS_BASE_URL = "https://ics-redux.ligo-la.caltech.edu/JIRA/secure/IssueNavigator.jspa?reset=true&customfield_";
var ICS_ASSY_URL = "https://ics-redux.ligo-la.caltech.edu/JIRA/browse/ASSY-";

function DisplayICSLink() {
   if (document.getElementById("ICSLink") === null) { return true; }
   var FNumber  = '10032';
   var title    = $('title').innerHTML;
   var html     = $('ICSLink').innerHTML;
   var atoms    = title.match(/(D)(\d{6,8})-[vx](\d+)/);
   if ( atoms && (atoms.length === 4) ) {
      var DNumber = atoms[2];
      title = $('DocTitle').innerHTML;
      if ( title.match(/[^\(\[][aA]ss(emb|y)/)) {
         FNumber = '10250';
      }
      var link = "<a href="+ICS_BASE_URL+FNumber+"=d"+DNumber;
      link += " target=_blank>d"+DNumber+"</a>";
      if ( $('DocTitle').innerHTML.match(/[sS]ys[a-z]*\s+[lL]ayout/)) {
         link = "<a href="+ICS_ASSY_URL+"D"+DNumber+"-NA";   
         link += " target=_blank>D"+DNumber+"-NA</a>";
      }
      html = html.replace('ICS_LINK', link);
      $('ICSLink').update(html);
      $('ICSLink').show();
   } else {
      $('ICSLink').hide();
   }
   return true;
}
