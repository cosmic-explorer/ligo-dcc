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
#MYSQL_DBS=(bugs wikidb dcc_docdb)
MYSQL_DBS=(dcc_docdb)
MYSQL_OPTS= 
MYSQLDUMP_OPTS="--single-transaction -f --default-character-set=utf8 --opt "
MYSQLDUMP_PATH="/home/dcc/dcc_docdb"
MYSQLDUMP_OUT=


REMOTE_HOSTS=(dcc-backup.ligo.org dcc-lho.ligo.org dcc-llo.ligo.org)
#REMOTE_HOSTS=(dcc-dev.ligo.org)

RSYNC_PATHS=(/usr1/www/html/public/)
FILE_RSYNC_PATHS=(/usr1/www/html/DocDB/)

SCRIPT_OUT=/tmp/resync_dcc-backup.txt

RSYNC_DIRS="${RSYNC_PATHS[*]} ${FILE_RSYNC_PATHS[*]}"

START_TIME=`$DATE +%s`
TODAY=$(date +%Y-%m-%d)

# plan the work
function dump_databases () {
	for MYSQL_DB in ${MYSQL_DBS}; do
	    MYSQLDUMP_OUT=$MYSQLDUMP_PATH/$MYSQL_DB\_${TODAY}.sql
	    echo "$MYSQLDUMP $MYSQLDUMP_OPTS $MYSQL_DB > $MYSQLDUMP_OUT" | ts
	    $MYSQLDUMP $MYSQLDUMP_OPTS $MYSQL_DB > $MYSQLDUMP_OUT

	    # compress the file in a separate step to avoir errorno 32
	    gzip --rsyncable  <${MYSQLDUMP_OUT} >${MYSQLDUMP_OUT}.gz
	done
}


# transform a common rsync path into an (hopefully) meaningful
# nickname without "/"
function dir_moniker() {
	sed 's!/!_!g' <<< ${1#/usr1/www/}
}

function rsync_files_list_for_dir () {
	  echo ${MYSQLDUMP_PATH}/rsync\_${TODAY}.txt
}

function plan_rsync () {
	HOW_FAR_BACK=${1:-7}
	OLD_PWD=$PWD
	RSYNC_FILE_LIST=$(rsync_files_list_for_dir)       
        2>/dev/null mysql dcc_docdb <<SQL_QUERY  | awk  '!/DocumentID.*Alias/ { printf("/usr1/www/html/DocDB/%04d/%s\n", $1, $2) }'  >$RSYNC_FILE_LIST
        select DISTINCT FLOOR(Document.DocumentID/1000), Document.Alias
        from Document, DocumentRevision,DocumentFile  
        where 
            Document.DocumentID=DocumentRevision.DocumentID 
          and 
 	    DocumentRevision.DocRevID= DocumentFile.DocRevID 
          and 
            TO_DAYS(NOW())-TO_DAYS(DocumentRevision.TimeStamp)<=$HOW_FAR_BACK
        ORDER BY Document.DocumentID desc ;
SQL_QUERY
	cd $OLD_PWD

}

function plan_rsync_new() {
	HOW_FAR_BACK=${1:-7}
	OLD_PWD=$PWD
	RSYNC_FILE_LIST=$(rsync_files_list_for_dir) 
	find /usr1/www/html/DocDB/*  -type d -prune -mtime -$HOW_FAR_BACK | grep -v Static  >$RSYNC_FILE_LIST
}

function execute_rsync () {
	OLD_PWD=$PWD
	# copy the data t  each host
	for DEST_HOST in ${REMOTE_HOSTS[*]}; do
	  # rsync files over
	  for RSYNC_DIR in ${RSYNC_DIRS} ; do
            SYNC_FILE_LIST=$(rsync_files_list_for_dir ${RSYNC_DIR})
            echo "restoring files from $RSYNC_DIR, according to $RSYNC_FILE_LIST to $DEST_HOST " | ts
            cd $RSYNC_DIR
			echo "cd $RSYNC_DIR"

            if [[ "$RSYNC_DIR" == *public/ ]] 
            then 
                $RSYNC $RSYNC_OPTS $FILE_RSYNC_OPTS $RSYNC_DIR $DEST_HOST:$RSYNC_DIR | ts
            else            
                xargs -t -a $RSYNC_FILE_LIST -I % $RSYNC $RYSNC_OPTS $FILE_RSYNC_OPTS -R  "%" $DEST_HOST:/ | ts
			    #$RSYNC $RYSNC_OPTS $FILE_RSYNC_OPTS -R  --files-from=$RSYNC_FILE_LIST / $DEST_HOST:/ | ts	
            fi
	    sleep 10 
    	done 
	done
    cd $OLD_PWD
}


function restore_dbs () {
	for DEST_HOST in ${REMOTE_HOSTS[*]}; do
	  for MYSQL_DB in ${MYSQL_DBS}; do
	    MYSQLDUMP_OUT=$MYSQLDUMP_PATH/$MYSQL_DB\_${TODAY}.sql
	    # copy over the mysql data
	    echo $SCP $MYSQLDUMP_OUT.gz $DEST_HOST:$MYSQLDUMP_OUT 1>> $SCRIPT_OUT | ts 
	    $SCP $MYSQLDUMP_OUT.gz $DEST_HOST:$MYSQLDUMP_OUT.gz  | ts
	  done
	  # Restore the database
	  echo $SSH $USER@$DEST_HOST  "cd $REMOTE_HOME; $REMOTE_COMMAND"  | ts
	  $SSH $USER@$DEST_HOST  "cd $REMOTE_HOME; $REMOTE_COMMAND" | ts        
	done
}


( dump_databases ; \
plan_rsync ; \
execute_rsync ; \
restore_dbs ) | tee /tmp/daily_resync.log |  mail -s "DCC Replication" philippe.grassia@ligo.org

#let's do the glimpse thing
parallel --will-cite rsync -avz --delete --hard-links /usr2/GLIMPSE/ "{}":/usr2/GLIMPSE/ ::: dcc-llo.ligo.org dcc-lho.ligo.org dcc-backup.ligo.org


# housekeeping 
find $MYSQLDUMP_PATH -name 'dcc_docdb*.sql' -mtime +1 -delete
