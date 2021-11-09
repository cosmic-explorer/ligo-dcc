#!/bin/bash


RSYNC_OPTS="-a"
FILE_RSYNC_OPTS="--verbose --archive --delete --hard-links" 
FILE_EXCLUDE_OPTS="--exclude=Static/"
REMOTE_HOME="/home/dcc"
REMOTE_COMMAND="./RestoreDCC"
MYSQL_DBS=(dcc_docdb)
MYSQL_OPTS= 
MYSQLDUMP_OPTS="--single-transaction -f --default-character-set=utf8 --opt "
MYSQLDUMP_PATH="/home/dcc/dcc_docdb"
MYSQLDUMP_OUT=

REMOTE_HOSTS=(dcc-backup.ligo.org dcc-lho.ligo.org) 

RSYNC_PATHS=(/usr1/www/html/public/ /usr1/www/html/DocDB/)

START_TIME=$(date)
DATE=$(date +%Y-%m-%d)

function prepare_db_dump () {
  MYSQL_DB=${1:-dcc_docdb}
  MYSQLDUMP_OUT=${MYSQLDUMP_PATH}/${MYSQL_DB}_${DATE}.sql
  echo "mysqldump ${MYSQLDUMP_OPTS} ${MYSQL_DB} > ${MYSQLDUMP_OUT}"  | ts
  nice mysqldump ${MYSQLDUMP_OPTS} ${MYSQL_DB} > ${MYSQLDUMP_OUT} 
}

function get_recent_files_for_rsync () {
  RSYNC_DIR=${1:-/usr1/www/html/DocDB/}
  BASEDIR=$(basename ${RSYNC_DIR})
  DAYS_AGO=${2:-7}
  RSYNC_FILES_OUT=${MYSQLDUMP_PATH}/${BASEDIR}_${DATE}.txt
  
  ts <(pushd ${RSYNC_DIR}) 
  pwd 

  find ./ -xtype f -mtime -7 | tee ${RSYNC_FILES_OUT} | ts
  ts <(popd) 
}

#prepare_db_dump dcc_docdb
get_recent_files_for_rsync /usr1/www/html/DocDB/

