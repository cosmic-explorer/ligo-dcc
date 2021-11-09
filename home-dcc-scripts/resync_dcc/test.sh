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
MYSQLDUMP_OPTS="-f -u backup -pbackmeup --opt dcc_docdb "
MYSQLDUMP_OUT=/home/dcc/dcc_docdb.sql
MYSQLDUMP_SIZE=/home/dcc/dcc_docdb_size.old
AGENT_INFO=/root/.ssh/agent-info

REMOTE_HOSTS=(dcc-lho.ligo-wa.caltech.edu)

RSYNC_PATHS=(/usr1/www/html/public/ /usr2/GLIMPSE/ /usr/local/)
FILE_RSYNC_PATHS=(/usr1/www/html/DocDB/)
SCP_PATHS=(/etc/httpd/conf/htdbmgroups.dir /etc/httpd/conf/htdbmgroups.pag)

SCRIPT_OUT=/tmp/resync_dcc-out.txt

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

$MYSQLDUMP $MYSQLDUMP_OPTS > $MYSQLDUMP_OUT
mysqldump_sz = `wc -l < $MYSQLDUMP_OUT`
if [$mysqldump_sz < $MYSQLDUMP_SIZE]; then
       wc -l < $MYSQLDUMP_OUT > $MYSQLDUMP_SIZE;
else
fi


# copy the data to each host
for DEST_HOST in ${REMOTE_HOSTS[*]}; do
        echo "Replicating to $DEST_HOST" >> $SCRIPT_OUT

        # copy over the mysql data
        echo $SCP $MYSQLDUMP_OUT $DEST_HOST:$MYSQLDUMP_OUT 1>> $SCRIPT_OUT 2>&1
        $SCP $MYSQLDUMP_OUT $DEST_HOST:$MYSQLDUMP_OUT 1>> $SCRIPT_OUT 2>&1

        # copy over group files
        for SCP_FILE in ${SCP_PATHS[*]}; do
                echo $SCP $SCP_FILE $DEST_HOST:$SCP_FILE 1>> $SCRIPT_OUT 2>&1
                $SCP $SCP_FILE $DEST_HOST:$SCP_FILE 1>> $SCRIPT_OUT 2>&1
        done

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

        echo "Replication to $DEST_HOST completed" >> $SCRIPT_OUT
done

rm -f $MYSQLDUMP_OUT

# if mail is setup this should probably/maybe/might work
mail -n -s "DCC Replication" araya_m@ligo.caltech.edu < $SCRIPT_OUT

rm -f $SCRIPT_OUT


