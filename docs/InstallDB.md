```bash 
#!/bin/bash

# honoring env variables:
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-example}
MYSQL_DATABASE=${MYSQL_DATABASE:-dcc_docdb}
MYSQL_USER=${MYSQL_USER:-docdbrw}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-docdbpwd}

sudo curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash

function install_database() {
# prepare database
    DATADIR=${1:-/var/lib/mysql}
    pkill mysqld
    rm -rf $DATADIR/* ~/.my.cnf
    /usr/bin/mysql_install_db --user=mysql --basedir=/usr --datadir=$DATADIR
    (/usr/sbin/mysqld --user=mysql 2> /tmp/mysqld.log & )
    for i in $(seq 10)
    do
       tail -n 1 /tmp/mysqld.log
       sleep 1
    done
    /usr/bin/mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"
    printf "[client]\nuser=root\npassword=$MYSQL_ROOT_PASSWORD\n" > /root/.my.cnf
    mysql -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -e "GRANT ALL ON *.* TO '$MYSQL_USER'@'localhost';"
    mysql -e "SELECT user, host, password FROM mysql.user ;"
    mysqladmin create $MYSQL_DATABASE
    mysql $MYSQL_DATABASE < /root/docdb_schema.sql
    mysql $MYSQL_DATABASE -e "show tables ;"
    /usr/bin/mysqladmin -u root "-p${MYSQL_ROOT_PASSWORD}" shutdown
}
```

empty DB schema [docdb_schema.sql](uploads/91ddc3b059f4bcd7dea8b4789dcaf69b/docdb_schema.sql)
Note: this schema uses the historical MyISAM storage engine and the latin1 character set. We are transitioning away from these. You can obtain a more current schema by applying the following sed substitution to the file before importing it:
```sed
s/MyISAM/innodb/g; s/latin1/utf8/g
```



[Configure Apache and filesystem](/philippe.grassia/dcc-india/wikis/ConfigureApache)

[Install and Configure awstats](/philippe.grassia/dcc-india/wikis/ConfigureAwstats)

[Install And Configure mediawiki](/philippe.grassia/dcc-india/wikis/InstallWiki)

[Install And Configure GLIMPSE](/philippe.grassia/dcc-india/wikis/InstallGLIMPSE)

[setup replication from CIT](/philippe.grassia/dcc-india/wikis/ConfigureReplication)