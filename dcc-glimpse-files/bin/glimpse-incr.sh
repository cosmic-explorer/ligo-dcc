#!/bin/bash
##
## Add new file to supplemental incremental
## glimpse index.
##
## This path DOES NOT create shadow entries,
## which are created by the synch script at
## 4 a.m.
##
## Phil Ehrens <pehrens@ligo.caltech.edu> 
##
## Philippe Grassia <philippe.grassia@ligo.org>
## 

QUEUE=${1:-incremental}
SHADOW=/usr2/GLIMPSE/shadow
LOGGER="echo"
tty -s || LOGGER="/usr/bin/logger -t glimpse-incremental"


if [ "$(id -un)" =  "apache" ]
then
  $LOGGER "running as apache user: check!"
  $LOGGER "Starting ${WORKER} listening to ${QUEUE}"
else
  $LOGGER "Actively refusing to run outside apache context"
  sleep 3600
  exit 
fi

## File types that should be ignored
ignore_rx='\.(1|2|3|4|5|6|7|8|9|aac|avi|bz2|cab|css|dat|dsdb|dwg|easm|edrw|eprt|fm|fpd|fpp|gif|gnt|graffle|gz|htaccess|iso|jpeg|jpg|key|lzw|m2ts|m4v|mkv|mov|mp2|mp3|mp4|mpeg|mpg|mts|odg|odp|ogg|ogm|pcm|png|schdoc|sld.{1,4}|step|tar|uda|vob|vsd|wav|wmv|x_[tb]|zar|zip)$'

## Must export GLIMPSE so that filters called by the "-z" option work.
export GLIMPSE=/usr2/GLIMPSE/dcc.glimpse.incremental



while :
do
  FILE_IN_QUEUE=$(/usr/bin/redis-cli BRPOP $QUEUE 0 | tail -n 1)
  echo "received ${FILE_IN_QUEUE}"
  # verify FILE_IN_QUEUE is a valid response  
  DEST="${SHADOW}${FILE_IN_QUEUE}"
  DEST_DIR=$(/usr/bin/dirname "${DEST}")
  
  if [ -f "$FILE_IN_QUEUE" ]
  then 
     # a single readable file
     if [ -f "$DEST" ]
     then
         $LOGGER "$FILE_IN_QUEUE already transcoded"
         # NOOP
         : 
     else
         extension="${FILE_IN_QUEUE##*.}"
         case $extension in
             "pdf"|"ps")
                $LOGGER "${WORKER} uses tika-app to transcode ${DEST}"
                 mkdir -p "${DEST_DIR}"
                 < "${FILE_IN_QUEUE}" nc localhost 9998 > "$DEST"
                 ;;
             *)   
                 $LOGGER "${WORKER} uses prefilter.tcl to transcode ${DEST}"
                 /usr/local/bin/prefilter.tcl "${FILE_IN_QUEUE}" > /dev/null
                 ;;
         esac
     fi
     # need to monitor semaphore for reset of /usr2/GLIMPSE/dcc.incremental
     while [ -f "${GLIMPSE}/.reset" ] 
     do 
 	sleep 0.1
     done 
     /usr/local/bin/glimpseindex -B -T -n -E -M 256 -w 1000 -H $GLIMPSE -a "${DEST}" >/dev/null 2>&1
     $LOGGER  "indexed file: '${FILE_IN_QUEUE}' "
  else 
     # Item to transcode does not exist or is not accessible
     $LOGGER "${FILE_IN_QUEUE} does not exist or is not readable by apache user"
  fi

done
