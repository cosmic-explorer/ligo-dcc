/*
  # ****************************************************************
  # Name: Signatures.js                                            #
  #                                                                #
  # Control code for the hierarchical signature editor AND         #
  # the resulting approval widget.                                 #
  #                                                                #
  # If you are unfamiliar with the Prototype JS library and it's   #
  # $$('css.selector') idiom, see:                                 #
  #                                                                #
  #    http://www.prototypejs.org/api/utility/dollar-dollar        #
  #                                                                #
  # Note that this code relies on the fact that $$() returns       #
  # elements in "document order" to avoid managing indices.        #
  #                                                                #
  # Phil Ehrens <pehrens@ligo.caltech.edu>                         #
  # ****************************************************************
*/

var REMOTEUSERCOMMENT = '';

function debug(aMsg) {
   setTimeout(function() { throw new Error("[debug] " + aMsg); }, 0);
}

// HTML prototype of a signature editor line.
// Uses the multiline XML trick.
var SIG = "<div class=sig><img class='sigb' src='/images/unchecked.png' /><select class='selectsigners' onKeypress='resizeSelect(this,12);' onKeyup='resizeSelect(this,1);'><option value=default>Select Signer</option></select></div>";

// CLS = 'mid' or 'bot'
// KRB = principal name.
// NAME is 'email,id'
var SIGNOFF = "<span class=CLS>KRB</span><input type=radio name=NAME value=abs onClick='signOff(STUFF,\"abs\");' /><span class=gry>Abstain</span><input type=radio name=NAME value=app onClick='signOff(STUFF,\"app\");' /><span class=grn>Approve</span><input type=radio name=NAME value=rej onClick='signOff(STUFF,\"rej\");' /><span class=red>Reject</span><span class=comm><textarea class=signercomment id=NAME onFocus='growComment(this);' onBlur='shrinkComment(this);'>Comment</textarea></span><br>";

// If there is an object with the id 'remote-user',
// fill it in. Callback for getRemoteUser().
function setUser(user) {
   var name = user.split('@')[0];
   $('remote-user').value  = name;
}

// Ajax call to be made at <body onLoad... or later,
// To get the name of the user.
function getRemoteUser() {
   if ($('remote-user')) {
      var url = 'remote-user.sh';
      new Ajax.Request(url, {
         onComplete: function(req) {
            setUser(req.responseText);
         }
      });
   }
}

//function highlightNextSigner() {
//   for (var i = 0; i < $$('li').length; i++) {
//      if ($$('li')[i].innerHTML.match(/waiting\s+for\s+signature/)) {
//         var html = $$('li')[i].innerHTML.sub('waiting for signature','<font color=red><b>waiting for signature</b></font>');
//         $$('li')[i].innerHTML = html;
//         return true;
//      }
//   }
//   return false;
//}

// Setup the signoff chooser with the state in the database
function setSignoffState(state) {
   if (typeof console !== 'undefined') {
      console.log("setSignoffState: "+state);
   }
   $('signoffstate').value  = state;
   listToSignatures(state);
}

function getSignoffState(docrevid) {
   if ($('signoffstate')) {
      var url = 'docdb-fetch-signoffstate.pl?'+docrevid;
      new Ajax.Request(url, {
         onComplete: function(req) {
            setSignoffState(req.responseText);
         }
      });
   }
}

// Manage the venetian blind effect of the select widgets.
function resizeSelect(el,rows) {
   $(el).size = rows;
}

// Augment array of signers and sort it.
// This is only EVER done once.
// Called by setSigners().
function sortRaw(raw) {
   var signers = [];
   var principal   = "";
   var name        = "";
   var email       = "";
   var authorid    = "";
   // signatures are based on emailuserid!
   var emailuserid = "";
   var tmp         = "";
   var opt         = "";
   raw = raw.split('|');
   for (var i=0; i<raw.length; ++i) {
       tmp = raw[i].split(',');
       principal   = tmp[0];
       name        = tmp[1];
       email       = tmp[2];
       authorid    = tmp[3];
       emailuserid = tmp[4];
       opt = '<option value='+email+','+emailuserid+'>'+principal+'</option>';
       signers[i] = {key:principal.split('.')[1],html:opt};
   }
   // A javascript custom sort routine
   signers.sort(function(a,b){
      if (a.key < b.key) return -1;
      if (a.key > b.key) return  1;
      return 0;
   });
   
   return signers;
}

// Populate the select widgets with the list of valid signers
function setSigners(raw) {
   var signer = $$('select.selectsigners');
   var data = sortRaw(raw);
   for (var i=0; i<data.length; ++i) {
       signer[0].insert(data[i].html);
   }
   signer[0].options[0].selected = true;
   
   // Deep copy any others that might exist (usually none).
   for (var j=1; j<signer.length; ++j) {
      signer[j].innerHTML = signer[0].innerHTML;
   }
   // Deep copy it for final signer as well.
   $('final-signer').innerHTML = signer[0].innerHTML; 
   $('final-signer').options[0].selected = true;
   $('final-signer').observe('change', walkSignatures);
   // MUST do this here or risk asynchronous hell
   getSignoffState(DOCREVID);
}

// Ajax call to be made at <body onLoad... or later,
// to populate the select widgets with the valid signers.
function getSignerList() {
   if ($('remote-user')) {
      var url = 'docdb-fetch-signers.pl';
      new Ajax.Request(url, {
         onComplete: function(req) {
            setSigners(req.responseText);
         }
      });
   }
}

// Handle the checkbutton state and manage the indentation.
// Note that this calls walkSignatures(), which then calls
// alignSig().
function toggleSigb() {
      var i = $$('img.sigb').indexOf(this);
   if ((this.src.match(/unchecked.png/)) &&
       ($$('select.selectsigners')[i].value !== "default")) {
      if ($$('select.selectsigners')[i-1].value !== "default") {
         $$('div.sig')[i].insert({before: SIG});
         registerNewSigner(i); 
         $$('img.sigb')[i+1].src = '/images/checked.png';
      } else {
         $$('img.sigb')[i].src = '/images/checked.png';
      }   
   } else {
      this.src = '/images/unchecked.png';
      if ($$('select.selectsigners')[i].value !== "default") {
         removeSigner(i-2);
      }
   }
   if (typeof console !== 'undefined') {
      console.log('Button State: '+this.src);
   }
   // Because we need to re-align the input widgets.
   walkSignatures();
}

// Dump the signature state to a formatted list
// And sanity check. From here it should go to
// the database.
function signaturesToList() {
   if ($('final-signer').value === "default") {
      alert("You did not select a Final Signer!");
      return false;
   }
   var stuff = "";
   var bstate = "";
   var signer = "";
   var divs = $$('div.sig');
   for (var i=0; i<divs.length; i++) {
      // Just want filename, not full URL
      bstate = $$('img.sigb')[i].src.split('/');
      bstate = bstate[(bstate.size() - 1)];
      signer = $$('select.selectsigners')[i].value;
      if (signer === "default") { continue; }
      stuff += bstate+','+signer+'|';
   }
   // Append the final signer as a last level
   stuff += 'checked.png,'+$('final-signer').value;
   // Simple check for hackers ;^)
   if (! stuff.match(/^((un)?checked.png,[a-z]+\.[a-z]+@LIGO.ORG,\d+\|?)+$/)) {
      if (typeof console !== 'undefined') {
         console.log('signaturesToList malformed input: '+stuff);
      }
      alert('signaturesToList:\n\n  Malformed input detected!');
      return false;
   } else {
   	return stuff;
   }
}

// Callback to create signature tree builder from database entry.
// This is kind of complicated, because it's creating a visual
// analog to the net logical result of user input.
// It can ALSO be used to brute-force clean the selection tree ;^)
function listToSignatures(stuff) {
   if (typeof console !== 'undefined') {
      console.log("listToSignatures: "+stuff);
   }
   // If there are no signoffs, don't do anything at all
   if (stuff.length < 3) { return true; } 
  
   var button = "";
   var email  = "";
   var id     = "";
   var i      = 0;
   var j      = 0;
   var level  = 0;   
   
   if ((stuff.length >= 6) && (databaseSanity(stuff) === false)) {
      alert('listToSignatures: FAIL!');
      return false;
   }
   
   var tmp    = stuff.split('|');
   var final_approver = tmp.last();
   var others = tmp.slice(0,(tmp.length - 1));
   
   // Remove the existing signature tree
   while ($$('div.sig')[0]) {
      $$('div.sig')[0].remove();
   }
   
   var len = $('final-signer').options.length;
   
   // Anonymous function on iterator
   others.each(function(thing) {
      button = thing.split(',')[0];
      email  = thing.split(',')[1];
      id     = thing.split(',')[2]; 
      // If button was checked, insert an extra.
      if ((i > 0) && (! button.match(/unchecked.png/))) {
         $('signatures').insert(SIG);
         $$('select.selectsigners')[i].update($('final-signer').innerHTML);
         alignSig(i,level);
         level++;
         i++;
      }
      $('signatures').insert(SIG);
      $$('select.selectsigners')[i].update($('final-signer').innerHTML);
      $$('img.sigb')[i].src = '/images/'+button;
      for (j=0; j<len; ++j) {
         if ($$('select.selectsigners')[i].options[j].value == email+','+id) {
             $$('select.selectsigners')[i].options[j].selected = true;
            break;
         }
      }
      alignSig(i,level);
      i++;
   });

   $('signatures').insert(SIG);
   $$('select.selectsigners')[i].innerHTML = $('final-signer').innerHTML;
   alignSig(i,level);
   observeSigDivs();
   listToSignaturesFinal(final_approver);
   return true;
}

// Split out code from listToSignatures
function listToSignaturesFinal(final_approver) {
   var email = final_approver.split(',')[1];
   var id    = final_approver.split(',')[2];
   var len = $('final-signer').options.length;
   for (var j=0; j<len; ++j) {
      if ($('final-signer').options[j].value == email+','+id) {
          $('final-signer').options[j].selected = true;
         break;
      }
   }
   return true;
}

function databaseSanity(stuff) {
   if (! stuff.match(/^[0-9a-zA-Z\-\.\,\@\|]+$/)) {
      alert('databaseSanity:\n\n  Malformed input detected!');
      return false;
   }
   var button = "";
   var signer = "";
   var tmp = stuff.split('|');
   for (i=0; i<tmp.length; i++) {
       button = tmp[i].split(',')[0];
       signer = tmp[i].split(',')[1];
       if (! button.match(/^(un)?checked.png$/)) {
          alert('databaseSanity:\n\n  Attempt to monkey with buttons detected!');
          return false;      
       }
       if (! signer.match(/^(|[a-z\.]+(@LIGO.ORG)?)$/)) {
          alert('databaseSanity:\n\n  Attempt to use illegal krb principal name  detected!');
          return false;
       }
   }
   return true;
}

// Walk the signature widget and grow and prune it as required.
function walkSignatures() {
   var tmp = "";
   var err = "";
   var used = new Object();
   // When we get here by selecting a valid name, 'here' will be > -1.
   var here = $$('select.selectsigners').indexOf(this);
   insertSignerAfter(here);
   var level     = -1;
   var button    = $$('img.sigb');
   var signer    = $$('select.selectsigners');
   button[0].src = '/images/checked.png';
   // get the final signer into the 'used' array if selected.
   tmp = $('final-signer').value.split('@')[0];
   if (tmp != "default") {
      used[tmp] = 1;
   }
   for (var i=0; i<signer.length; i++) {      
      // increment on checked buttons only.
      if (! button[i].src.match(/unchecked.png/)) {
         level++;
      }
      // Prune empty spare signature inputs
      if (signer[i].value == "default") {
         removeSigner(i);
      } else {
         // Manage the 'used' array to detect duplications.
         tmp = signer[i].value.split('@')[0];
         if (used[tmp] === undefined) {
            used[tmp] = 1;
         } else {
            err += 'Attempt to assign duplicate signer rejected:\n\n    '+tmp+'\n\n';
            $$('select.selectsigners')[i].options[0].selected = true;
         }
      }
      alignSig(i,level);
   }
   // Check to see if an additional input is needed
   if (this.value !== undefined) {  
      appendSignerAtBottom(i);
      alignSig(i,level);
      if (typeof console !== 'undefined') {
         console.log('Button level: '+level+' Text: '+this.value);
      }
   }
   // alert duplications
   if (err.length > 0) {
      alert(err);
      return false;   
   }
   // Finally, write the value that will be submitted.
   var stuff = signaturesToList();
   $('signoffstate').value = stuff;
   if (typeof console !== 'undefined') {
      console.log('SignoffState: '+stuff);
   }
   return true;
}

// Insert a new signature widget if appropriate
function insertSignerAfter(i) {
   if (($$('select.selectsigners')[i] !== undefined)       &&
       ($$('select.selectsigners')[i].value !== "default") &&
       ($$('select.selectsigners')[i+1])                   &&
       ($$('select.selectsigners')[i+1].value !== "default")) {
      $$('div.sig')[i].insert({after: SIG});
      registerNewSigner(i+1);
   }
}

// Indent the signature list
function alignSig(i,level) {
   if ($$('img.sigb')[i]) {
   	// Returns, for example '28px'
   	var W = $$('img.sigb')[i].getStyle('width');
   	// So strip the 'px' part
   	W = W.match(/\d+/);
   	// And 'french' it a bit 
   	W = Math.round(W * 1.2);
   	// Indent!
   	$$('img.sigb')[i].setStyle({marginLeft: (W * level)+'px'});
   }
}

// Add a line if it's needed
function appendSignerAtBottom(i) {
   // Assigning this to a variable here prevents memory leaks below.
   var signer = $$('select.selectsigners');
   if (signer[i-1] && (signer[i-1].value !== "default")) {
      // The next line modifies the select.selectsigners array...
      $('signatures').insert(SIG);
      registerNewSigner(i);
   }
} 

// Abstraction of often reused code
function registerNewSigner(i) {
   $$('div.sig')[i].innerHTML = $$('div.sig')[0].innerHTML;
   $$('img.sigb')[i].src = '/images/unchecked.png';
   $$('select.selectsigners')[i].options[0].selected = true;
   $$('img.sigb')[i].observe('click', toggleSigb);
   $$('select.selectsigners')[i].observe('change', walkSignatures);
}

// Prune off un-needed lines starting with the topmost
function removeSigner(i) {
   while (($$('div.sig')[i+1]) &&
          ($$('img.sigb')[i+1].src.match(/unchecked.png/)) && 
          ($$('select.selectsigners')[i+1].value == "default")) {
      $$('div.sig')[i+1].remove();
   }
}

// Call from <body onLoad... or later to register existing signature divs
function observeSigDivs() {
   var divs = $$('div.sig');
   for (var i=0; i<divs.length; i++) {
	   Element.stopObserving($$('img.sigb')[i], 'click', toggleSigb);
	   Element.stopObserving($$('select.selectsigners')[i], 'change', walkSignatures);

      $$('img.sigb')[i].observe('click', toggleSigb);
      $$('select.selectsigners')[i].observe('change', walkSignatures);
   }
   if (typeof console !== 'undefined') {
      console.log('observeSigDivs initialised '+divs.length+' signature entries.');
   }
}

// Get signature hierarchy from database and create the
// signoff widget (the button thing).
function getSigs(stuff) {
   var level  = 1;
   var midbot = "";
   var button = "";
   var signer = "";
   var emailuserid = "";
   var tmp    = "";
   if (typeof console !== 'undefined') {
     console.log('Signatures Dump: \''+stuff+'\'');
   }
   
   if (stuff.length < 6) {
      $('ShowDocSignOffs').hide();
   } else if (databaseSanity(stuff) === false) {
      return false;
   }

   $('signoffs').innerHTML = '';   

   // Build the new signoff tree (restore the tree from the database).
   stuff = stuff.split('|');
   for (i=0; i<stuff.length; ++i) {       
      if (midbot === 'bot') {
         $('signoffs').insert('<span class=vbar></span><br>');
         level++;
      }
      midbot = 'mid';
      tmp = SIGNOFF;
      
      if (stuff[i+1]) {
         button = stuff[i+1].split(',')[0];
         if (! button.match(/unchecked.png/)) {
            midbot = 'bot';
         }
      } else {
         midbot = 'bot';
      }

      var pieces = stuff[i].split(',');
      var stuffing = '"'+pieces[1]+'","'+pieces[2]+'"';
      signer = stuff[i].split(',')[1]; 
      signer = signer.split('@')[0];
      emailuserid = stuff[i].split(',')[2];
      tmp = tmp.sub('CLS',   '\"'+midbot+' sigbut\"', 1);
      tmp = tmp.sub('KRB',   signer, 1);
      tmp = tmp.sub('NAME',  signer, 4);
      tmp = tmp.sub('STUFF', stuffing, 3);
      $('signoffs').insert(tmp);
      removeComment(signer,emailuserid);      
      $$('span.sigbut')[i].setStyle({marginLeft: (30 * level)+'px'});
      if ($$('span.vbar')[level-2]) {
          $$('span.vbar')[level-2].setStyle({marginLeft: (30 * level)+'px'});
      }
   }
   return true;
}

function stuffGetSigs(docrevid) {
   if ($('signoffs')) {
      var url = 'docdb-fetch-signoffstate.pl?'+docrevid;
      new Ajax.Request(url, {
         onComplete: function(req) {
            getSigs(req.responseText);
            disableSignoffs();
         }
      });
   }
}

function disableSignoffs() {
   var user = $('remote-user').value;
   var buttons = $$('div#signoffs>input');
   for (i=0; i<buttons.length; ++i) {
       buttons[i].disable();
   }
   try {
        // If the current user is a signer, let them pound buttons. 
        var owned = $$('div#signoffs>input[name='+user+']');
        for (i=0; i<owned.length; ++i) {
           owned[i].enable();
        }
   }
   catch(oops) {
      if (typeof console !== 'undefined') {
         console.log('disableSignoffs: No button group for user'+user);
      }
   }
}

function signOff(name,id,state) {
   var user = $('remote-user').value;
   if (typeof console !== 'undefined') {
      console.log('signOff: '+id+' '+user+' '+state);
   }
}

function commentToDb() {
   var user = $('remote-user').value;
   // There can only ever be one, the current one.
   var comment = $$('textarea.signercomment')[0].value;
   $$('textarea.signercomment')[0].value = '';
   updateSignoffNote(user, comment);
   if (typeof console !== 'undefined') {
      console.log('commentToDb: Comment for user '+user+': \"'+comment+'\" docRevId: '+DOCREVID);
   }
   stuffGetSigs(DOCREVID);
}

function updateSignoffNoteCallback(err) {
   if (typeof console !== 'undefined') {
      console.log('updateSignoffNote: '+err);
   }
}

function updateSignoffNote(user, note) {
   REMOTEUSERCOMMENT = note;
   var url = 'docdb-update-signoffnote.pl';
   new Ajax.Request(url, {
      parameters: { docrevid: DOCREVID, emailuserid: EMAILUSERID, note: note },
      onComplete: function(req) {
      updateSignoffNoteCallback(req.responseText);
      }
   });
}

function growComment(el) {
   var html  = "<span id='b_and_c'>\n   <br>\n";
       html += "   <input type=button value='Commit' onClick='commentToDb();'/>\n";
       html += "   <span class='counter'>0/250 Words (max)</span>\n</span>";
   if (el.id !== $('remote-user').value) {
      return false;
   }
   if (el.value == "Comment") {
      el.value = REMOTEUSERCOMMENT;
   }
   if (el.style.width !== '400px') {
      el.style.width = '400px';
      el.style.height = '200px';
      el.insert({after: html});
      el.observe('click', countWords);
      el.observe('keyup', countWords);
   }
   retrieveComment(el);
   return true;
}

function shrinkComment(el) {
   if ((el.value.match(/^\s*$/)) || (el.value.length < 3)) {
      el.value        = "Comment";
      el.style.width  = '4.5em';
      el.style.height = '1.2em';
      // eat up the span with the button and counter
      $('b_and_c').remove();
   }
}

function removeComment(name,id) {
   var user = $('remote-user').value;
   if (name !== user) {
      var html = '<span class=\"hover-comment\" id=\"';
      html += id;
      html += '\" onClick=\"stickComment(this);\"';
      html += '>View Comment</span>';
      $(name).replace(html);
   }
}

function displayComment(retval) {
   var comments = retval.split('|');
   for (i=0; i<comments.length; ++i) {
       var id = comments[i];
       ++i;
       var state = comments[i];
       if (state.length === 0) {
          state = 0;
       }
       ++i;
       var comment = comments[i];
       if (comment.length === 0) {
          comment = 'No comment.';
       }
       if (typeof console !== 'undefined') {
          console.log(id+' '+state+' "'+comment+'"');
       }
       if (id == EMAILUSERID) {
          REMOTEUSERCOMMENT = comment;
          $($('remote-user').value).value = comment;
       } else {
          $(id).style.display = 'inline-block';
          $(id).style.margin = '0.5ex';
          $(id).style.padding = '0.5ex';
          $(id).update(comment);
       }
   }
}

function retrieveComment(el) {
   var url = 'docdb-fetch-signoffnote.pl?'+DOCREVID;
   new Ajax.Request(url, {
      onComplete: function(req) {
         displayComment(req.responseText);
      }
   });
}

function hideComment(el) {
   el.style.display = 'inline';
   el.style.padding = '0px';
   el.innerHTML = 'View Comment';
}

function stickComment(el) {
   var html = el.innerHTML;
   if (html == "View Comment") {
      retrieveComment(el);
   } else {
      hideComment(el);
   }
}

function countChars() {
   var N = $(this).value.length;
   if (N > 750) {
      $(this).value = $(this).value.slice(0,750);
      $(this.name+'_N').update("<font color=red>Input truncated to 750 characters!</font>");
   } else {
      $(this.name+'_N').update(N+"/750");
   }   
}

function countWords() {
   var N = 0;
   var X = $(this).value.split(' ');
   for (var Z = 0; Z < X.length; Z++) {
      if ( X[Z].length > 0) { 
         N++;
      }
   }
   if (N > 250) {
      $(this).value = $(this).OLD;
      // There can only ever be one - The one belonging to REMOTE_USER
      $$('span.counter')[0].update("<font color=red>Input truncated to 250 words!</font>");
   } else {
      $$('span.counter')[0].update(N+"/250 Words (max)");
      $(this).OLD = $(this).value;
   }   
}


