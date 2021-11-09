#!/bin/ksh

##*********************************************************
## Incautious use of perl CGI can result in arbitrarily
## large temp files with names like /var/tmp/CGItemp12345
## that must be cleaned up to prevent the root filesystem
## from getting used up!
##
## Run from /etc/cron.hourly
##
## Phil Ehrens
##
##*********************************************************


day=86400

now=$(date +%s)

for file in /usr1/www/cgi-bin/tmp/CGItemp*
do
  mtime=$(stat --format=%Z $file 2>/dev/null)
  if [[ -n $mtime && $(($now - $mtime)) -gt $day ]]
  then
    logger -t cleanupcgitempfiles.sh "deleting stale perl CGI temp file: $file"
    rm -f $file
  fi
done
