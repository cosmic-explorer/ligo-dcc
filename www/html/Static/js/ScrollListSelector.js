/*
 *
 * This code supports the "View Groups" and "Modify Groups"
 * Selection boxes in DocumentAddForm.
 *
 */

function security_list_deselector (list) {

    var publicPending =  1;
    var obsolete      = 43;
    var optionsValue  =  0;
    var securityValue =  0;

    if (typeof(list.options[list.selectedIndex]) != 'undefined') {
       optionsValue = list.options[list.selectedIndex].value;
    }
    
    if ((optionsValue == publicPending) || (optionsValue == obsolete)) {
         var securityArray = document.forms[0].security;
       
         for (var i = 0; i < securityArray.length; i++) {
             if (securityArray[i] != list) {
                 for (var j = 0; j < securityArray[i].options.length; j++) {
                      securityArray[i].options[j].selected = false;
                 }
             } else {
                 for (var j = 0; j < securityArray[i].options.length ; j++) {
                      if (j != list.selectedIndex) {
                          securityArray[i].options[j].selected = false;
                      }
                 }
             }
         }
    } else {
         var securityArray = document.forms[0].security;
         for (var i = 0; i < securityArray.length; i++) {
             for (var j = 0; j < securityArray[i].options.length; j++) {
                 securityValue = securityArray[i].options[j].value;
                 if ((securityValue == publicPending) || (securityValue == obsolete)){
                      securityArray[i].options[j].selected = false;
                 }
             }
         }
    }

}
