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
