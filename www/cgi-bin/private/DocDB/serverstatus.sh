#!/bin/ksh

html=$(</usr1/www/cgi-bin/private/DocDB/serverstatus.html)

if [ -n "$html" ]; then
   date=`/bin/date`
   content="$html<p>Status message last updated at: $date"
else
   content=""
fi

print "Content-Type: text/html

$content"
