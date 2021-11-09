#!/usr/bin/tclsh

set debug 0

set rx {<th>([AENT][a-zA-Z\s]+):[^0-9]+([0-9\.]+).+} 

set URL https://dcc.ligo.org/cgi-bin/private/DocDB/Statistics

set curl_cmd "/usr/bin/curl -silent --insecure --negotiate --user foo:foo $URL"

set now [ clock seconds ]
set now [ clock format $now -format %Y%m%d ]

#set data [ eval exec $curl_cmd ]

set here [ pwd ]
cd /usr1/www/cgi-bin/private/DocDB
set data [ exec /usr1/www/cgi-bin/private/DocDB/Statistics ]
cd $here

set row $now
set names "\"Date\""

foreach line [ split $data "\n" ] {
   if { [ regexp $rx $line -> key value ] } {
      if { $debug } { puts "$key : $value" }
      append row   " $value"
      append names " \"$key\""
   }
}

if { $debug } {
   puts "${row}\n${names}"
} else {
   puts $row
}

