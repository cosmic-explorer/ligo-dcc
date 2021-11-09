// Remove leading and trailing spaces
function trim(s) {
   return s.replace(/^\s+|\s+$/, '');
}

// POC - ASCII printable character set
function asciiGen() {
   if (typeof(console) !== 'undefined') {
      for(var i=32; i<127; i++) {
         console.log(String.fromCharCode(i));
      }
   }
}
