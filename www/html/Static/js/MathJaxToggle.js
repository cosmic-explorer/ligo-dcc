/***********************************************************
 *
 * The $ object used to manipulate DOM is NOT FROM JQUERY
 *
 * it is from PROTOTYPE.JS 
 *
 ***********************************************************/


function Toggle_Renderer() {
  var renderer_name = "CommonHTML";
  if (MathJax.Hub.config.menuSettings.renderer != 'PlainSource') {
     renderer_name = "PlainSource";
  }
  MathJax.Hub.setRenderer(renderer_name);
  MathJax.Hub.Config({render:renderer_name});
}

function RefreshMath() {
  MathJax.Hub.Reprocess();
}

function ShowMathJaxButton() {
   //Transitional from hyperlink/button to checkbox
   //
   if (!($("MathJax_Toggle") || $("MathJax_Check"))&& $("MathJax-Element-1")) {
     $("MathJaxInsert").insert(
       "<p style='margin-left:2em;'>\n"+
       "<a href='Javascript:helppopupwindow(\"/cgi-bin/private/DocDB/DocDBHelp?term=whatismathjax\");'><img src='https://www.mathjax.org/badge/logo_60x12.gif' /></a>: \n" +
/*       "<button onclick='Toggle_Renderer();' id='MathJax_Toggle'></button>\n"+ */
       "<input type='checkbox' id='MathJax_Check' onclick='Toggle_Renderer();' >" +
       "</p>\n"
       );
   }

   var mjx_chk=$("MathJax_Check");
   if (mjx_chk) { 
      mjx_chk.checked = (MathJax.Hub.config.menuSettings.renderer != 'PlainSource') ;
   }
}


document.addEventListener('DOMContentLoaded', (event) => {
    MathJax.Hub.Config({  
         tex2jax: {
             inlineMath: [['\\(','\\)']],
             processEscapes: true
         },
         CommonHTML: { linebreaks: { automatic: true } },
         "HTML-CSS": { linebreaks: { automatic: true } },
         SVG: { linebreaks: { automatic: true } }, 
         PlainSource: {   ".MathJax_PlainSource_Display": {
             "text-align": "center",
             margin: ".75em 0px",
             "white-space": "pre", 
             display: "block"
      } }
    });
    MathJax.Hub.Register.MessageHook("End Math", ShowMathJaxButton);
    MathJax.Hub.Register.MessageHook("Renderer Selected", RefreshMath);
})

