// Roy Williams - April 2012
// takes multiple selects and copies selections to a textarea

jQuery.noConflict();

var isfocused = 0;
function unfocus(){
  isfocused = 0;
}
function packValues(event, from, to) {
  if (isfocused==0){
    isfocused = 1;
    return;
  }
  var mySelect = document.getElementById(from);
  var packed   = document.getElementById(to).value;

  for (var i = 0; i < mySelect.options.length; i++) {
    if (mySelect.options[i].selected){
      if(packed != "") packed += "\n"
      packed += mySelect.options[i].text;
    }
  }
  document.getElementById(to).value = packed;
}

function checkNames(){
//    console.log("check names");
    document.getElementById('AuthorTextError').innerHTML = "";
    var text = document.getElementById('authormanual').value;
    if(text == ""){
        return;
    }

    var names = text.split("\n");
    message = "";
    for(var n=0; n<names.length; n++){
        nn = names[n].replace(/^\s+/, '').replace(/\s+$/, '').toLowerCase();
 //       console.log("|"+nn+"|");
        found = 0;
        if(nn == "") {
            found = 1;
            continue;
        }

        for(var i=0; i<AuthorFormal.length; i++){
//            if(nn.indexOf(AuthorFormal[i]) >= 0){
            if(nn == AuthorFormal[i].toLowerCase()){
                found = 1;
            }
        }
        if (!found){
            message += nn + '\n';
        }
    }
    if(message == ""){
        return;
    }
    m = '<font color="red">Warning: Unknown author:<br/>' + message + '</font>';
    document.getElementById('AuthorTextError').innerHTML = m;
//    alert("Warning: Unknown author:\n" + message);
}

jQuery(document).ready(function(){
  initTextarea();
});
function initTextarea(){ 
  var list = AuthorFormal;
  jQuery("#authormanualdiv textarea").autocomplete({ 
    wordCount:1,
    on: { 
      query: function(text,cb){
        var words = [];
//        var text = textt.replace(/^\s+|\s+$/g, '');
//      console.log("|"+text.toLowerCase()+"|")
        for( var i=0; i<list.length; i++ ){
          if( list[i].toLowerCase().indexOf(text.toLowerCase()) >= 0 ) words.push(list[i]); 
          if( words.length > 100 ){
//            words.push(" ... too many");
            break; 
          } 
        } 
        cb(words);                  
      } 
    } 
  });

  jQuery("#requestersmanualdiv textarea").autocomplete({ 
    wordCount:1,
    on: { 
      query: function(text,cb){
        var words = [];
        for( var i=0; i<list.length; i++ ){
          if( list[i].toLowerCase().indexOf(text.toLowerCase()) >= 0 ) words.push(list[i]); 
          if( words.length > 100 ){
//            words.push("... too many");
            break; 
          } 
        } 
        cb(words);                  
      } 
    } 
  });

  jQuery("#signoffdiv textarea").autocomplete({ 
    wordCount:1,
    on: { 
      query: function(text,cb){
        var words = [];
        for( var i=0; i<Signers.length; i++ ){
          if( Signers[i].toLowerCase().indexOf(text.toLowerCase()) >= 0 ) words.push(Signers[i]); 
          if( words.length > 100 ){
//            words.push("... too many");
            break; 
          } 
        } 
        cb(words);                  
      } 
    } 
  });

  jQuery('#authors').bind('keypress scroll', function(e){
   var charCode = e.charCode || e.keyCode || e.which;
   if (charCode == 13 ) {
     e.preventDefault();
     packValues(e, 'authors','authormanual');
   }
  });

  jQuery('#requesters').bind('keypress', function(e){
   var charCode = e.charCode || e.keyCode || e.which;
   if (charCode == 13 ) {
     e.preventDefault();
     packValues(e, 'requesters','requestersmanual');
   }
  });
  jQuery('#signoffscroll').bind('keypress', function(e){
   var charCode = e.charCode || e.keyCode || e.which;
   if (charCode == 13 ) {
     e.preventDefault();
     packValues(e, 'signoffscroll','signofflist');
   }
  });
}

function removeDuplicates(arr) {
    return arr.filter((item,index) => arr.indexOf(item) === index);
}

function autocomplete_textarea(selectID, textareaID) {
    jQuery('#'+selectID).hide();
    jQuery("#"+textareaID)
    // don't navigate away from the field on tab when selecting an item
      .on( "keydown", function( event ) {
        if ( event.keyCode === jQuery.ui.keyCode.TAB &&
            jQuery(this).autocomplete( "instance" ).menu.active ) {
          event.preventDefault();
        }
      })
      .focusout( function() {
        console.log(textareaID+' lost focus, updating '+selectID);
        var terms=this.value.trim().split(/\n\s*/);
        var options=jQuery("#"+selectID+" > option");
        options.each(function() {
           this.selected = terms.includes(this.text);
        })
      })
      .autocomplete({
        minLength: 0,
        position: { my: "left bottom", at: "center top", collision: "fit" },
        source: function( request, response ) {
          var lines=request.term.split(/\n\s*/);
          // compute line to figure out where the edition is currently taking place
          var tArea = this.element[0];
          var line_number = tArea.value.substr(0, tArea.selectionStart).split("\n").length-1;
          var search_term= lines[line_number];
          response( jQuery.ui.autocomplete.filter(
                  AuthorFormal, search_term
               )
          );
          return false;
        },
        select: function( event, ui ) {
            // ```this``` is not the same object that ```this``` in previous function
            // here ```this``` is the textarea
            var terms = this.value.trim().split(/\n\s*/);
            var line_number = this.value.substr(0, this.selectionStart).split("\n").length-1;
            terms[line_number] = ui.item.value;
            // add placeholder to get the empty line at the end
            terms.push( "" );
            this.value = removeDuplicates(terms).join( "\n" );
            event.preventDefault();
                          // or return false;
        },
        focus: function (event, ui) {
            // avoid erasing the content of the textarea when selecting with the keyboard
            var terms = this.value.trim().split(/\n\s*/);
            var line_number = this.value.substr(0, this.selectionStart).split("\n").length-1;
            terms[line_number] = ui.item.value;
            // add placeholder to get the empty line at the end
            terms.push( "" );
            this.value = removeDuplicates(terms).join( "\n" );
            // Prevent the default focus behavior.
            event.preventDefault();
              // or return false;
        }
      });
}


/*
 * dynamically created an autocomplete widget
 * boxID defines the namespace from which various elements names and IDs are derived
 * the current implementation "just" creates a list of single value inputs
 * from a cgi standpoint this is a list of strings
 */
function add_Autocomplete(boxID){
     var element = jQuery("#list"+boxID);
     var number  = 1 + jQuery("#list"+boxID+" > div").length;
     var new_id  = "_in_"+boxID+"_"+(number+Math.random());

     element.append("<div>  <input id='"+new_id+"' class='ui-widget class_"+boxID+"' name='"+boxID+"' value=''/>" +
       "  <span class='fa fa-eraser' onclick='jQuery(this).parent().remove();'/></span>"+
       "</div>"
     );
     var new_elt = jQuery(".class_"+boxID);
     new_elt.autocomplete({
                   source: AuthorFormal,
                   select: function( event, ui ) {
                        add_Autocomplete(boxID);
                     }
                 });
     new_elt.focus();
 }
