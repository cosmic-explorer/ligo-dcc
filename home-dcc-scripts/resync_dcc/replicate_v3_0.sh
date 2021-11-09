#!/bin/bash

RSYNC=/usr/bin/rsync
SCP=/usr/bin/scp
SSH=/usr/bin/ssh
SSHADD=/usr/bin/ssh-add
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
DATE=/bin/date
TIME=/usr/bin/time

RSYNC_OPTS="-a -e ssh"
FILE_RSYNC_OPTS="--verbose --archive --delete --hard-links" 
FILE_EXCLUDE_OPTS="--exclude=Static*/"
MYSQL_OPTS= 
DOCDBDUMP_OPTS="-f -u backup -pbackmeup --opt dcc_docdb "
DOCDBDUMP_OUT=/home/dcc/dcc_upgrade/dcc_docdb_$(date +%Y-%m-%d).sql
WIKIDBDUMP_OPTS="-f -u backup -pbackmeup --opt wikidb "
WIKIDBDUMP_OUT=/home/dcc/dcc_upgrade/wikidb_$(date +%Y-%m-%d).sql
BUGSDUMP_OPTS="-f -u backup -pbackmeup --opt bugs "
BUGSDUMP_OUT=/home/dcc/dcc_upgrade/bugs_$(date +%Y-%m-%d).sql
AGENT_INFO=/root/.ssh/agent-info

REMOTE_HOSTS=(dcc-backup.ligo.org)

SCRIPT_OUT=/tmp/dcc-v2_4_0-out.txt

echo "Replication script started" `$DATE` > $SCRIPT_OUT

# load the ssh-agent info
if [ -e $AGENT_INFO ]; then
        . $AGENT_INFO
else
        echo "$AGENT_INFO not found, can not load ssh-agent info" >> $SCRIPT_OUT
        exit 1
fi

$SSHADD -l
if [ $? -ne 0 ]; then
        echo "ssh-agent not initialized or no key loaded" >> $SCRIPT_OUT
        exit 1
fi

$MYSQLDUMP $DOCDBDUMP_OPTS > $DOCDBDUMP_OUT
$MYSQLDUMP $WIKIDBDUMP_OPTS > $WIKIDBDUMP_OUT
$MYSQLDUMP $BUGSDUMP_OPTS > $BUGSDUMP_OUT

# copy the data to each host
for DEST_HOST in ${REMOTE_HOSTS[*]}; do
        echo "Replicating to $DEST_HOST" >> $SCRIPT_OUT

        # copy over the mysql data
        echo $SCP $DOCDBDUMP_OUT $DEST_HOST:$DOCDBDUMP_OUT 1>> $SCRIPT_OUT 2>&1
        $SCP $DOCDBDUMP_OUT $DEST_HOST:$DOCDBDUMP_OUT 1>> $SCRIPT_OUT 2>&1
        echo $SCP $WIKIDBDUMP_OUT $DEST_HOST:$WIKIDBDUMP_OUT 1>> $SCRIPT_OUT 2>&1
        $SCP $WIKIDBDUMP_OUT $DEST_HOST:$WIKIDBDUMP_OUT 1>> $SCRIPT_OUT 2>&1
        echo $SCP $BUGSDUMP_OUT $DEST_HOST:$BUGSDUMP_OUT 1>> $SCRIPT_OUT 2>&1
        $SCP $BUGSDUMP_OUT $DEST_HOST:$BUGSDUMP_OUT 1>> $SCRIPT_OUT 2>&1

        # copy over group files
        #for SCP_FILE in ${SCP_PATHS[*]}; do
        #        echo $SCP $SCP_FILE $DEST_HOST:$SCP_FILE 1>> $SCRIPT_OUT 2>&1
        #        $SCP $SCP_FILE $DEST_HOST:$SCP_FILE 1>> $SCRIPT_OUT 2>&1
        #done

        #for RSYNC_DIR in ${RSYNC_PATHS[*]}; do
        #        echo $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR 1>> $SCRIPT_OUT 2>&1
        #        $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR 1>> $SCRIPT_OUT 2>&1
        #done
        # rsync more files over
        #for RSYNC_DIR in ${FILE_RSYNC_PATHS[*]}; do
        #        echo $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR $FILE_EXCLUDE_OPTS  1>> $SCRIPT_OUT 2>&1
        #        $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR $FILE_EXCLUDE_OPTS  1>> $SCRIPT_OUT 2>&1
        #done

        echo "Replication to $DEST_HOST completed" >> $SCRIPT_OUT
done

#rm -f $MYSQLDUMP_OUT

# if mail is setup this should probably/maybe/might work
mail -n -s "$REMOTE_HOST Replication" araya_m@ligo.caltech.edu < $SCRIPT_OUT

rm -f $SCRIPT_OUT


