FROM mariadb:10

ARG MARIADB_ROOT_PASSWORD=changeme
ARG MARIADB_DATABASE=dcc_docdb
ARG MARIADB_USER=docdbrw
ARG MARIADB_PASSWORD
ARG MARIADB_USER2=docdbro
ARG MARIADB_PASSWORD2

# fully stocked with a reference database
ADD *.sql /docker-entrypoint-initdb.d/

RUN printenv

