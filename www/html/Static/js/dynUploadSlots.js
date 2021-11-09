function changeUploadSlots(ev) {
  maxfiles= ev.target.value;
  for (var slot=1; slot<=maxfiles; slot+=1) {
    var uploadSlot=$('upload'+slot);
    if ( !uploadSlot ) {
      var ElementName = "upload"+slot;
      var DescName    = "filedesc"+slot;
      var MainName    = "main"+slot;
      var FileIDName  = "fileid"+slot;
      var CopyName    = "copyfile"+slot;
      var URLName     = "url"+slot;
      var NewName     = "newname"+slot;
      dynUploadSlots=$('dynamicUploadSlots').tBodies[0];
      console.log("need to build uploadslot #"+slot);
      dynUploadSlots.insert( "<tr><th>&nbsp;</th><td> &nbsp;</td></tr>\n");
      dynUploadSlots.insert( "<tr> \
            <th><strong><a class='Help' href='javascript:helppopupwindow(\"DocDBHelp?term=localfile\");'>File:</a></strong></th> \
            <td> \
		<input type='file' name='"+ElementName+"' size='60' maxlength='250' onchange='validateFilename(this);' id='"+ElementName+"'> \
            </td></tr>");
      dynUploadSlots.insert( "<tr> \
            <th><strong><a class='Help'  href='javascript:helppopupwindow(\"DocDBHelp?term=description\");'>Description:</a></strong></th> \
            <td> \
               <input type='text' name='"+DescName+"' size='60' maxlength='128'><span style='padding:0 1em;'>\
               <input type='checkbox' name='"+MainName+"' value='on'></span>\
<!--               <strong><a href='javascript:helppopupwindow(\"DocDBHelp?term=main\");'>Main ?</a></strong> --> \
           </td></tr>" );

    }
  }	
  var dynamicTable= $('dynamicUploadSlots');
  var targetNumberofRows= parseInt(maxfiles)*3;

  while(dynamicTable.rows.length > targetNumberofRows) {
     dynamicTable.deleteRow(-1);
  }
  dynamicTable.rows[dynamicTable.rows.length-1].bgcolor="#f00";
  console.log("number of rows: "+dynamicTable.rows.length);
}


