#!/bin/bash
##
## Build the glimpse index for the dcc
##
## Requires a few minutes!!
##
##

if [ "$(id -un)" =  "apache" ]
then
  echo "running as apache user: check!"
else
  echo "refusing to run outside apache context"
  exit 
fi

systemctl status workers.target 


basedir='/usr2/GLIMPSE'
base='dcc.glimpse'
docdb=/usr1/www/html/DocDB
export GLIMPSE="${basedir}/${base}.new"
shadow="$basedir/shadow"
idxbase=$basedir/$base
incridx=${idxbase}.incremental

REDIS_QUEUE=textify
PARTITIONS=3

# Removed "-z" option to support shadowing!
glimpsecmd='/usr/local/bin/glimpseindex -b -B -t -n -S 50 -M 512 -w 1000 -H'
# seed for the incremental index
incrinitcmd="/usr/local/bin/glimpseindex -B -n -M 256 -w 1000 -H $incridx -f /etc/host.conf"
errmsg="Something is wrong. Please examine the files in $GLIMPSE"

echo "Creating $GLIMPSE"
mkdir -p $basedir
mkdir -p ${shadow}${docdb}

#reset glimpse incr early 
mkdir -p ${incridx}
# set a semaphore file to prevent increment over initial 
touch "${incridx}/.reset"
find  "${incridx}" -type f -name '.glimpse*' -delete
$incrinitcmd
rm -f "${incridx}/.reset"



echo "Making sure $REDIS_QUEUE is empty"
while true 
do 
  pending=$(/usr/bin/redis-cli llen $REDIS_QUEUE| sed '/(.*)/d' )
  echo "Still $pending items pending transcoding"
  [ "$pending" -eq "0" ] &&  break 
  sleep 10 
done

BUCKETS=$(find $docdb -mindepth 1 -maxdepth 1 -type d -printf '%Ts\t'$shadow'%p\n' | sort -nr | cut -f2 )

let "PARTSIZE = "$( wc -w <<<$BUCKETS)"/$PARTITIONS+1"

PARTNUM=1
xargs -n $PARTSIZE <<< $BUCKETS | while read -r BUCKET_LIST 
do
  echo "Running glimpseindex #${PARTNUM} against $BUCKET_LIST"
  
  /bin/mkdir -p --mode=0755 ${GLIMPSE}
  $glimpsecmd ${GLIMPSE} $BUCKET_LIST
  rm -rf "${basedir}/${base}${PARTNUM}"
  echo "moving ${GLIMPSE} to ${basedir}/${base}${PARTNUM}"
  mv "${GLIMPSE}" "${basedir}/${base}${PARTNUM}"

  let "PARTNUM=$PARTNUM+1"
done



