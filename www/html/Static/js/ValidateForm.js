/*
 * ValidateForm.js
 *
 * Requires prototype.js
 *
 * To use, add this to the form declaration:
 *
 * onSubmit=>'="return validateForm(this);"'
*/

// Do we have the REQUIRED Prototype Library?
if (typeof(window.Prototype) == "undefined") {
   alert("FATAL ERROR: The Prototype Javascript Library is REQUIRED.");
}

var E_TRAVELER_BOOL = 0;
var FILE_UPLOADS_BOOL = 0;

//Phil Ehrens Apr 2013
// Determine whether approval chain should be reset
// based on metadata update values.
var ATLOAD   = new Hash();
var ATSUBMIT = new Hash();

var inputBGcolors = new Hash();

// Scoring hash for form fields:
//    0: Changing this field has no implied effect
//    1: Changing this field will reset the signature chain
var FORM_FIELDS = new Hash();
var FORM_HUMAN = new Hash();
FORM_FIELDS.set('mode',         0);
FORM_FIELDS.set('upload',       1);
FORM_HUMAN.set('upload', 'Hidden Field: upload');
FORM_FIELDS.set('archive',      1);
FORM_HUMAN.set('archive', 'Hidden Field: archive');
FORM_FIELDS.set('docid',        1);
FORM_HUMAN.set('docid', 'Hidden Field: docid');
FORM_FIELDS.set('oldversion',   1);
FORM_HUMAN.set('oldversion', 'Hidden Field: oldversion');
FORM_FIELDS.set('uniqueid',     1);
FORM_HUMAN.set('uniqueid', 'Hidden Field: uniqueid');
FORM_FIELDS.set('version',      1);
FORM_HUMAN.set('version', 'Hidden Field: version');
FORM_FIELDS.set('overdate',     1);
FORM_HUMAN.set('overdate', 'Hidden Field: overdate');
FORM_FIELDS.set('special',      1);
FORM_HUMAN.set('special', 'Hidden Field: special');
FORM_FIELDS.set('title',        1);
FORM_HUMAN.set('title', 'Title');
FORM_FIELDS.set('abstract',     1);
FORM_HUMAN.set('abstract', 'Abstract');
FORM_FIELDS.set('keywords',     0);
FORM_FIELDS.set('revisionnote', 1);
FORM_HUMAN.set('revisionnote', 'Notes and Changes');
FORM_FIELDS.set('maxfiles',     0);
// **********************************************************
//
// BIG FAT NOTE:
//
// There can be N fileid's, filedesc's, upload's, and main's
//
// **********************************************************
FORM_FIELDS.set('fileid1',      1);
FORM_HUMAN.set('fileid1', 'Hidden Field: fileid');
// filedesc can be set to DELETE! The file will be hidden.
FORM_FIELDS.set('filedesc1',    1);
FORM_HUMAN.set('filedesc1', 'File Description');
FORM_FIELDS.set('upload1',      1);
FORM_HUMAN.set('upload1', 'Hidden Field: upload');
FORM_FIELDS.set('copyfile1',      1);
FORM_HUMAN.set('copyfile1', 'Hidden Field: copyfile');
// mainN is always 0
FORM_FIELDS.set('main1',        0);
// **********************************************************
FORM_FIELDS.set('doctype',      1);
FORM_HUMAN.set('doctype', 'Document Type');
// The VIEW ACL
FORM_FIELDS.set('security',     0);
FORM_HUMAN.set('security', 'View Groups');
FORM_FIELDS.set('modify',       0);
FORM_HUMAN.set('modify', 'Modify Groups');
FORM_FIELDS.set('authors',      0);
FORM_HUMAN.set('authors', 'Authors');
FORM_FIELDS.set('authormanual', 0);
FORM_HUMAN.set('authormanual', 'Authors');
FORM_FIELDS.set('authorgroups', 0);
FORM_FIELDS.set('topics',       0);
FORM_HUMAN.set('topics', 'Topics');
FORM_FIELDS.set('events',       0);
FORM_FIELDS.set('xrefs',        0);
FORM_FIELDS.set('journal',      0);
FORM_FIELDS.set('volume',       0);
FORM_FIELDS.set('page',         0);
FORM_FIELDS.set('pubinfo',      0);
// Test this when Roy fixes it!!
FORM_FIELDS.set('signofflist',  1);
FORM_FIELDS.set('status',       0);
FORM_FIELDS.set('nsigned',      0);
FORM_FIELDS.set('public',       0);
FORM_FIELDS.set('oldnumber',    0);
FORM_FIELDS.set('LessFiles',    0);
FORM_HUMAN.set('oldnumber', 'Old DCC Document Number');
FORM_FIELDS.set('qastat',       0);
FORM_HUMAN.set('qastat', 'QC Certify');
// This is the variable that will be used by the Perl code on submit:
// '1' to reset, '0' to not reset.
FORM_FIELDS.set('reset',        0);
FORM_FIELDS.set('requester',    1);
FORM_HUMAN.set('requester', 'Hidden Field: requester');
FORM_FIELDS.set('olddocrevid',       0);
FORM_HUMAN.set('olddocrevid', 'Hidden Field: olddocrevid');
FORM_FIELDS.set('parallelsignoff',       1);
FORM_HUMAN.set('parallelsignoff', 'Parallel Signoff');
FORM_FIELDS.set('clearinactive', 0);
FORM_HUMAN.set('clearinactive', 'Hidden Field: clearinactive');


function getCorrectFormID(form) {
   var formid = '';
   if ((typeof(form) == 'string') && (form.length > 0)) {
      formid = form;
   } else {
      for (var i=0; i<document.forms.length; i++) {
         if (document.forms[i].id.length > 0) {
            formid = document.forms[i].id;
            if (typeof(console) !== 'undefined') {
               console.log('document: '+formid);
            }
            break;
         }
      }
   }
   if (typeof(console) !== 'undefined') {
      console.log('getCorrectFormID: '+formid);
   }
   if (formid.length === 0) {
      alert("FATAL ERROR: Could not determine id of form!\nExpect further errors!");
   }
   return formid;
}

function validateForm(form) {
   var formid = getCorrectFormID(form);
   if (validateUploads(formid)  === false) { return false; }
   if (validateNewReservation() === false) { return false; }
   return formHasChanged(formid);
}

function validateClone(form) {
   console.log ("In ValidateClone");
   var doctitle = $("title").innerHTML.split(';')[2];
   var doctype = doctitle[0];
   return confirm("Cloning "+ doctitle + " will create a new "+doctype+"-document \n"+
                  "with the same Title, Abstract and other metadata, but\n" +
                  "without copying the data files");
}

function validateUploads(formid) {
   var filename = '';
   var form = $(formid).serialize();
   parseSerializedForm(form, 'ATSUBMIT');
   var reason = '';
   var elements = ATSUBMIT.keys();
   for (var i=0; i<elements.length; i++) {
      if (elements[i].match(/^upload\d+$/)){
         filename = $$('*[name="'+elements[i]+'"]')[0].value;
         if (filename.length > 0) {
            FILE_UPLOADS_BOOL = 1;
            if (typeof(console) !== 'undefined') {
               console.log('FILE_UPLOADS_BOOL set to 1 for: '+filename)
            }
            reason += validateFilename(elements[i]);
         }
      }
   }
   if (reason.length > 0) {
      alert("Some form fields need correction:\n\n"+reason);
      return false;
   } else {
      return true;
   }
}

function appendSignoffPublicMsg(msg) {
   if (msg.match(/signoff/)) {
      msg += "\nClick 'OK' to proceed and reset signoff state,\n"
      msg += "or click 'Cancel' to return to form.";
   } else if (msg.match(/reset/)) {
      msg += "\nClick 'OK' to proceed and unset public status,\n"
      msg += "or click 'Cancel' to return to form.";
   }
   return msg;
}

/*
 * fields fileid, filedesc, upload, and main are "extensible"
 * and can have integers appended to them to be iterated.
 *
 * I thought this was a good idea, but after dealing with this
 * and THEN dealing with the not-uniquely-identified multiple
 * input model, I think I prefer the latter.
 *
 * See the functions initBGcolor() and yellowBGcolor() for
 * examples of handling the multiple "identical" widgets.
 */
function handleIterableKeys(key) {
   var extended;
   if (typeof(FORM_FIELDS.get(key)) == 'undefined') {
      extended = key.match(/^\D+/)[0]+'1';
      FORM_FIELDS.set(key, FORM_FIELDS.get(extended));
      FORM_HUMAN.set(key, FORM_HUMAN.get(extended)+' '+key.match(/\d+$/));
   }
}

/*
 * The next two functions were required because rather than using
 * unique "id's" or even unique names, things like "Topics" are
 * managed in docdb by creating multiple input widgets that are
 * NOT UNIQUELY IDENTIFIED... In other words, multiple inputs
 * share the same exact name.
 *
 * This is legal, and reasonable, but remember that it means
 * everything must be assumed to be a collection, and iterated
 * over.
 */
function initBGcolor(key) {
   var el = $$('*[name="'+key+'"]');
   if (el[0].type.match(/(radio|checkbox|submit)/)) {
      return;
   }
   for (var i=0; i<el.length; i++) { 
      if (typeof inputBGcolors.get(key) == 'undefined') {
         inputBGcolors.set(key, el[i].getStyle('backgroundColor'));
      }
      el[i].setStyle({backgroundColor: inputBGcolors.get(key)});
   }
}

function yellowBGcolor(key) {
   var el = $$('*[name="'+key+'"]');
   if (el[0].type.match(/(radio|checkbox|submit)/)) {
      return;
   }
   for (var i=0; i<el.length; i++) { 
      el[i].setStyle({backgroundColor: 'yellow'});
      el[i].observe('click', function(event) {
          initBGcolor(this.name);
          event.stop();
      });
   }
}

function formHasChanged(formid) {
   var ucvar = formid.toUpperCase();
   var key, reset, el;
   var warn = false;
   var decide = false;
   var changed = false;
   var securitychanged = false;
   var zerodata = eval(ucvar+'_LOADSTATE');
   var formdata = $(formid).serialize();
   parseSerializedForm(zerodata, 'ATLOAD');
   parseSerializedForm(formdata, 'ATSUBMIT');

   // Debugging output when FireBug (or other "console") is in use
   if (typeof(console) !== 'undefined') {
      console.log('qacertified: '+ATLOAD.get('qastat')+'| signstatus: '+ATLOAD.get('status')+'| mode: '+ATLOAD.get('mode')+'| public: \''+ATLOAD.get('public')+'\'');
   }

   // Reserving a new document requires different validation, we
   // aren't looking for changes, we're looking for missing required
   // fields or invalid content.
   if (ATLOAD.get('mode').match(/(new|reserve|use)/)) {
      return validateNewReservation();
    }

   if ((ATLOAD.get('nsigned') !== '0') &&
       (ATLOAD.get('public').length == 0) &&
       (E_TRAVELER_BOOL !== 1)) {
      var msg =  "Fields you have changed will cause the signoff state\n";
          msg += "and 'public' status of this document to be reset:\n\n";
   } else if ((ATLOAD.get('nsigned') !== '0') &&
             (ATLOAD.get('qastat') == 1) &&
             (E_TRAVELER_BOOL !== 1)) {
      var msg =  "Fields you have changed will cause the signoff state\n";
          msg += "and 'QA Certify' status of this document to be reset:\n\n";
   } else if ((ATLOAD.get('nsigned') !== '0') &&
              (E_TRAVELER_BOOL !== 1)) {
       var msg =  "Fields you have changed will cause the\n";
           msg += "signoff state of this document to be reset:\n\n";
   } else if ((ATLOAD.get('public').length == 0) &&
              (E_TRAVELER_BOOL !== 1)) {
        var msg =  "Fields you have changed will cause the\n";
            msg += "'public' status of this document to be reset:\n\n";
   } else if ((ATLOAD.get('qastat') == 1) &&
              (E_TRAVELER_BOOL !== 1)) {
        var msg =  "Fields you have changed will cause the\n";
            msg += "'QA Certify' status of this document to be reset:\n\n";
   } else {
      var msg = '';
   }
  
   // Specifically to handle the 'create new version' case -
   // Status will be the status of the new version, no effect
   // on the old version. 
   if (ATLOAD.get('mode').match(/^update$/)) {
      if (typeof(msg) !== 'undefined') {
         msg = '';
      }
   }

   if (FILE_UPLOADS_BOOL == 1) {
      if (msg.length > 0) {
         msg += "Uploading file(s)\n";
      } else {
         warn = true;
      }
      changed = true;
   }

   if (ATLOAD.get('mode').match(/add/)) {
      return validateFileAddition(msg);
   }

   // Iterate over all form inputs to detect changes
   var elements = ATLOAD.keys();
   for(var i=0; i<elements.length; i++){
      key = elements[i];

      handleIterableKeys(key);
      
      if (typeof(ATSUBMIT.get(key)) == 'undefined') {
         ATSUBMIT.set(key, '');
      }      

      if (ATLOAD.get(key) !== ATSUBMIT.get(key)) {
         changed = true;
         if (key == 'security') { securitychanged = true; }
         reset = FORM_FIELDS.get(key);
         if (reset !== 0 && msg.length > 0) {
            if (typeof(FORM_HUMAN.get(key)) !== 'undefined') {
               msg += FORM_HUMAN.get(key)+"\n";
            } else {
               msg += key+"\n";
            }
            warn = true;
            initBGcolor(key);
            yellowBGcolor(key);
         }
         if (typeof(console) !== 'undefined') {
            console.log(key+': \''+ATLOAD.get(key)+'\' -> \''+ATSUBMIT.get(key)+'\' reset: '+reset);
         }
      }
   }
   
   if (E_TRAVELER_BOOL == 1) { warn = false; }
   
   msg = appendSignoffPublicMsg(msg);
 
   if (typeof(console) !== 'undefined') {
      console.log('warn: '+warn);
   }

   if (warn === true) {
      $('reset').value = 1;
      if (msg.length > 0) {
         return confirm(msg);
      } else {
         return true;
      }
   } else if ((warn === false) && (securitychanged === true)) {
      $('reset').value = 2;
      if (ATLOAD.get('public').length === 0) {
         msg = 'View Groups Changed. Public Status will be revoked.';
         return confirm(msg);
      } else if (ATLOAD.get('qastat') == 1) {
         msg = 'View Groups Changed. QA Certification will be removed.';
         return confirm(msg);
      } else {
         return true;
      }
   } else if (changed === false) {
      alert('Form unchanged. No action to be taken.');
      return false;
   } else {
      $('reset').value = 0;
      return true;
   }
}

function parseSerializedForm(data, hash) {
   var key, value;
   var oldkey = '';
   var item = new Array();
   var tokens = data.split('&').sort();
   var files = $$('[type="file"]');
   
   for (var i = 0; i < tokens.length; i++) {
      item = tokens[i].split('=');
      key   = decodeURIComponent(item[0]);
      value = decodeURIComponent(item[1]);
      if ((hash !== 'ATLOAD') &&
          (typeof(ATLOAD.get(key))) == 'undefined') {
         ATLOAD.set(key, '');
      }
      // Because we have multiple inputs with the same name
      if (key == oldkey) {
         value = eval(hash).get(key)+' '+value;
      }
      oldkey = key;
      if ( 0 && (typeof(console) !== 'undefined')) {
         console.log(key+': '+value);
      }
      eval(hash).set(key, value.trim());
   }
   
   for (var i = 0; i < files.length; i++) {
      key   = files[i].name;
      value = files[i].value;
      eval(hash).set(key, value.trim());
   }
   
   // Special code for E-Travelers - UGLY!
   var etraveler_rx = /^\s*[A-Z]\d{6,8}\.[0-9a-f]{40}/;
   if (typeof($$('[name="fileid1"]')[0]) !== 'undefined') {
      var fname = $$('[name="fileid1"]')[0].up(0).innerHTML;
      if (fname.match(etraveler_rx)) {
         E_TRAVELER_BOOL = 1;
      }
   }
   if (E_TRAVELER_BOOL === 0) {
      var alt_etraveler_rx = /\([A-Z]\d{6,8}\.[0-9a-f]{40}\,/;
      var listitems = $$('li');
      for (var i=0; i<listitems.length; i++) {
         if (listitems[i].innerHTML.match(alt_etraveler_rx)) {
            E_TRAVELER_BOOL = 1;
            break;
         }
      }
   }
   if (E_TRAVELER_BOOL == 1) {
      if (typeof(console) !== 'undefined') {
         console.log("Document is an E-Traveler!");
      }
   }   
}

function validateFilename(name) {
    var char = '';
    var error = ''; 
    var illstring = '';
    var firstChars = /^([\s\.\-~;]).*/;
    var illegalChars= /[^ #%\(\)\+,\-\.0-9:@A-Z\[\]\^_a-z~]/;
    
    if (typeof name == "string") { 
       var el = $$('*[name="'+name+'"]')[0];
       var fname = el.value;
    } else {
       var formid = getCorrectFormID(name);
       return validateUploads(formid);
    }

    // Some really broken browsers pass weird semi-invented
    // upload file PATHS instead of just filenames.
    // They look like: C:\my\browser\sucks.eggs
    //
    // Note that this does funny things to files
    // named, for example foon\\bar.baz
    fname = fname.match(/[^\\\/]+$/)[0];

    if (fname.match(firstChars)) {
       error = "The file name "+fname+"\ncannot begin with any of ' .~-;'";
       el.parentNode.innerHTML = el.parentNode.innerHTML;
    } else if (fname.match(illegalChars)) {
       initBGcolor(name);
       yellowBGcolor(name);
       
       for (var i=0; i<fname.length; i++) {
          char = fname.substring(i,i+1);
          if (char.match(illegalChars)) {
             illstring += char;
          }
       }
       error = "The file name "+fname+"\ncontains illegal characters: "+illstring;
       el.parentNode.innerHTML = el.parentNode.innerHTML;
    } else {
       initBGcolor(name);
    }
    return error;
}

/*
 * Validate existence and format of required values for reserved document.
 */
function validateNewReservation() {
   var errors = '';
   var human = '';
   var el = '';
   var pubviewable = ATSUBMIT.get('public');
   var mode = ATSUBMIT.get('mode');
   var required = new Array("oldnumber","title","doctype","security","modify","authormanual","topics");
   for (var i=0; i<required.length; i++) { 
      el = $$('*[name="'+required[i]+'"]')[0];
      // "oldnumber" is not always defined
      if (typeof el == 'undefined') { continue }
      if (mode.match(/update/) && (required[i] == 'security') && (pubviewable.length == 0)) { continue }
      initBGcolor(required[i]);
      if (typeof(console) !== 'undefined') {
         console.log(required[i]+": '"+ATSUBMIT.get(required[i])+"'");
      }
      if ((typeof ATSUBMIT.get(required[i]) == 'undefined') ||
         (ATSUBMIT.get(required[i]).match(/(^$|^\s+$|undefined)/))) {
         human = FORM_HUMAN.get(required[i]);
         errors += "Missing required value: \n"+human+"\n";
         yellowBGcolor(required[i]);
      }
   }
   if (errors.length) {
      alert(errors);
      return false;
   }
   return true;
}

function validateFileAddition(msg) {
   if (FILE_UPLOADS_BOOL == 1) {
      if (msg.length > 0) {
         return confirm(msg);
      }
   } else {
      alert('You must supply a file to add to the document.');
      return false;
   }
}
