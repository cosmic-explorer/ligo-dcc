#!/bin/ksh
read slop
crap=`env`
auth=$(</tmp/mygroup.out)

logfile=/tmp/dcc-shibtest-logfile

print -- "Content-Type: text/html

<h3>Things that came through STDIN:</h3>
<pre>
$slop
</pre>
<p>
<h3>Things that came from the environment:</h3>
<pre>
$crap
</pre>
<p>
<h3>Things that the auth.sh script saw:</h3>
<pre>
$auth
</pre>
"
set -o noglob
print -- "$slop\n\n$crap\n\n$auth" >>$logfile
