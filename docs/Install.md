# From a vanilla SL 7.6+ installation
- add epel repository
- add shibboleth repository
- add ius repository
- add mariadb repository

# install packages and update ([requirements.yum](uploads/3c637bb1d228d09059d798bf0dd4589d/requirements.yum))

httpd
perl
mod_perl
httpd_utils
mod_auth
mod_ssl
mod_authnz_external
openssl
vim
mariadb-server
mariadb
mysql-utilities
ksh
perl-CGI
perl-Sys-Syslog
perl-DBI
perl-Digest-SHA1
perl-DBD-MySQL
shibboleth
rsync
php72u-cli
mod-php72u
php72u-mysqlnd

[Install and populate Database](InstallDB)

[Configure Apache and filesystem](ConfigureApache)

[Install and Configure awstats](ConfigureAwstats)


[Install And Configure GLIMPSE](InstallGLIMPSE)

[setup replication from CIT](ConfigureReplication)
