#!/bin/bash

SSH=/usr/bin/ssh/
USER=root
RSYNC=/usr/bin/rsync
SCP=/usr/bin/scp
SSH=/usr/bin/ssh
SSHADD=/usr/bin/ssh-add
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
DATE=/bin/date
TIME=/usr/bin/time
LOGGER=/usr/bin/logger

RSYNC_OPTS="-a"
FILE_RSYNC_OPTS="--verbose --archive --delete --hard-links" 
FILE_EXCLUDE_OPTS="--exclude=Static/"
REMOTE_HOME="/home/dcc"
REMOTE_COMMAND="./RestoreDCC"
MYSQL_DBS=(dcc_docdb wikidb bugs)
MYSQL_OPTS= 
MYSQLDUMP_OPTS="-f -u backup  -pbackmeup --opt "
MYSQLDUMP_PATH="/home/dcc/dcc_docdb"
MYSQLDUMP_OUT=
AGENT_INFO=/root/.ssh/agent-info

REMOTE_HOSTS=(dcc-backup.ligo.org)
#REMOTE_HOSTS=(131.215.125.40)

RSYNC_PATHS=(/usr1/www/html/public/)
FILE_RSYNC_PATHS=(/usr1/www/html/DocDB/)

SCRIPT_OUT=/tmp/resync_dcc-backup.txt


START_TIME=`$DATE +%s`

# load the ssh-agent info
#if [ -e $AGENT_INFO ]; then
#        . $AGENT_INFO
#else
#        echo "$AGENT_INFO not found, can not load ssh-agent info" >> $SCRIPT_OUT
#        exit 1
#fi
#
#$SSHADD -l
#if [ $? -ne 0 ]; then
#        echo "ssh-agent not initialized or no key loaded" >> $SCRIPT_OUT
#        exit 1
#fi

# copy the data to each host
for DEST_HOST in ${REMOTE_HOSTS[*]}; do
        echo "$DEST_HOST Replication script started" `$DATE` > $SCRIPT_OUT
        echo "Replicating to $DEST_HOST" >> $SCRIPT_OUT

#        for MYSQL_DB in ${MYSQL_DBS[*]}; do
#            MYSQLDUMP_OUT=$MYSQLDUMP_PATH/$MYSQL_DB\_$(date +%Y-%m-%d).sql
#            echo $MYSQLDUMP_OUT
#            echo "$MYSQLDUMP $MYSQLDUMP_OPTS $MYSQL_DB > $MYSQLDUMP_OUT"
#            $MYSQLDUMP $MYSQLDUMP_OPTS $MYSQL_DB > $MYSQLDUMP_OUT
        
            # compress the file
#            gzip $MYSQLDUMP_OUT

            # copy over the mysql data
#            echo $SCP $MYSQLDUMP_OUT.gz $DEST_HOST:$MYSQLDUMP_OUT 1>> $SCRIPT_OUT 2>&1
#            $SCP $MYSQLDUMP_OUT.gz $DEST_HOST:$MYSQLDUMP_OUT.gz 1>> $SCRIPT_OUT 2>&1

#            rm -f $MYSQLDUMP_OUT.gz
#        done

        # rsync files over
        for RSYNC_DIR in ${RSYNC_PATHS[*]}; do
                echo $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR 1>> $SCRIPT_OUT 2>&1
                $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR 1>> $SCRIPT_OUT 2>&1
        done
        # rsync more files over
        for RSYNC_DIR in ${FILE_RSYNC_PATHS[*]}; do
                echo $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR $FILE_EXCLUDE_OPTS  1>> $SCRIPT_OUT 2>&1
                $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR $FILE_EXCLUDE_OPTS  1>> $SCRIPT_OUT 2>&1
        done

        # Restore the database
        echo $SSH $USER@$DEST_HOST  "cd $REMOTE_HOME; $REMOTE_COMMAND" >> $SCRIPT_OUT 2>&1
        $SSH $USER@$DEST_HOST  "cd $REMOTE_HOME; $REMOTE_COMMAND" >> $SCRIPT_OUT 2>&1

        echo "Replication to $DEST_HOST completed" >> $SCRIPT_OUT
        mail -n -s "$DEST_HOST Replication" araya_m@ligo.caltech.edu < $SCRIPT_OUT
done


# if mail is setup this should probably/maybe/might work

rm -f $SCRIPT_OUT

END_TIME=`$DATE +%s`

$LOGGER -t $0 "Wall time to complete: $(($END_TIME - $START_TIME)) seconds"
