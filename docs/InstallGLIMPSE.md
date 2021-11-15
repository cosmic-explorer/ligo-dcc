

## Compile and install glimpse
- download source from http://webglimpse.net/trial/glimpse-latest.tar.gz
- extract tarball
- install development tools
```
yum install -y @"Development Tools" flex flex-devel
```
- usual ```./configure && make && make install```

## install companion programs needed to run the indexing jobs :

- ``` yum install -i tcl xpdf poppler ```
- create crontab execute /root/glimpse-runner
```
#!/bin/sh

ts=`/bin/date +%s`
/usr/local/bin/glimpse-init.sh >/root/glimpse-init.REPORT."$ts" 2>&1 &
```

- copy /usr/local/bin/glimpse-init.sh
```shell
#!/bin/ksh
##
## Build the glimpse index for the dcc
##
## Requires a few minutes!!
##
## Note that debugging is automatically enabled
## when the script is run from a terminal (tty).
##
basedir='/usr2/GLIMPSE'
base='dcc.glimpse'
docdb=/usr1/www/html/DocDB
export GLIMPSE="$basedir/$base.new"
shadow="$basedir/shadow$docdb"
idxbase=$basedir/$base
incridx=${idxbase}.incremental

prefiltercmd=/usr/local/bin/prefilter.tcl
# Removed "-z" option to support shadowing!
glimpsecmd='/usr/local/bin/glimpseindex -b -B -t -T -n -E -S 100 -M 128 -w 1000 -H'
# seed for the incremental index
incrinitcmd="/usr/local/bin/glimpseindex -B -T -n -E -M 128 -w 1000 -H $incridx -f /etc/host.conf"
errmsg="Something is wrong. Please examine the files in $GLIMPSE"

tty -s && echo "Creating $GLIMPSE"
tty -s || rm -rf  $GLIMPSE
tty -s && rm -vrf $GLIMPSE
tty -s || /bin/mkdir -p    --mode=0700 $GLIMPSE
tty -s && /bin/mkdir -v -p --mode=0700 $GLIMPSE
# INDEX SHADOW!
tty -s || $prefiltercmd $docdb
tty -s && echo "Running prefilter.tcl against $docdb"
tty -s && time $prefiltercmd $docdb
tty -s || $glimpsecmd $GLIMPSE $shadow 2>&1 >/dev/null
tty -s && echo "Running glimpseindex against $shadow"
tty -s && time $glimpsecmd $GLIMPSE $shadow

# we don't need no awk!
set -A foo $(/bin/ls -sl $GLIMPSE/.glimpse_index)
indexsize=${foo[5]}
tty -s && echo "Size of $GLIMPSE/.glimpse_index : $indexsize"
if [[ "$indexsize" -lt 20000000 ]] ; then
  tty -s || logger -t dcc.glimpse $errmsg
  tty -s && echo $errmsg
  exit
fi

tty -s || /bin/rm -rf  $idxbase
tty -s && /bin/rm -vrf $idxbase
tty -s || mv -f  $GLIMPSE $idxbase
tty -s && mv -vf $GLIMPSE $idxbase
tty -s || /bin/rm -rf  $incridx
tty -s && /bin/rm -vrf $incridx
tty -s || /bin/mkdir -p  --mode=0700 $incridx
tty -s && /bin/mkdir -vp --mode=0700 $incridx
${incrinitcmd};
tty -s || chown -R  apache:apache $basedir
tty -s && chown -vR apache:apache $basedir
unset GLIMPSE
tty -s || logger -t dcc.glimpse "New glimpse indices created in $idxbase and $incridx"
tty -s && echo "New glimpse indices created in $idxbase and $incridx"
```

