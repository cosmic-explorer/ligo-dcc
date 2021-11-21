FROM debian:bullseye-slim as base

ARG PERL_TEST_OPTION="--notest"
ARG MARIADB_ROOT_PASSWORD=changeme
ARG MARIADB_DATABASE=dcc_docdb
ARG MARIADB_USER=docdbrw
ARG MARIADB_PASSWORD
ARG MARIADB_USER2=docdbro
ARG MARIADB_PASSWORD2

ENV DOCDB_BASE=/usr1/www
ENV DOCDB_CGI_DIR=${DOCDB_BASE}/cgi-bin
ENV DOCDB_HTML_DIR=${DOCDB_BASE}/html
ENV DEBIAN_FRONTEND=noninteractive
ENV PERL5LIB=/usr1/www/cgi-bin/private/DocDB

ENV MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD}
ENV MARIADB_DATABASE=${MARIADB_DATABASE}
ENV MARIADB_USER=${MARIADB_USER}
ENV MARIADB_PASSWORD=${MARIADB_PASSWORD}
ENV MARIADB_USER2=${MARIADB_USER2}
ENV MARIADB_PASSWORD2=${MARIADB_PASSWORD2}

SHELL ["/bin/bash", "-l", "-c"]

RUN apt update && apt upgrade -y &&\
    apt install -y apache2 supervisor perlbrew build-essential \
                   libexpat1-dev \
                   default-libmysqlclient-dev libmariadb-dev-compat mariadb-client \
                   tmux vim curl ksh tcl &&\
    mkdir -p ${DOCDB_CGI_DIR} ${DOCDB_HTML_DIR}

#setup perl environment
# @INC started excluding "." at perl 5.26 in 2017
#  -Udefault_inc_excludes_dot might not work for long
RUN apt install -y libcgi-untaint-perl cpanminus j2cli
# j2cli for jinja2 templates


COPY docker/cpanfile ${DOCDB_BASE}
RUN  cd ${DOCDB_BASE} && cpanm --cpanfile cpanfile --installdeps ${PERL_TEST_OPTION} .

####
## building the actual container is about done at this point
## I should make more extensive cleanup to reduce the size of the final
## image : purge packages needed only to build the image, clean apt's cache etc
#####
RUN apt-get clean

COPY docker/docdb.sh /tmp/
RUN chown -R www-data. ${DOCDB_HTML_DIR}/ &&\
    bash /tmp/docdb.sh > /etc/apache2/sites-available/docdb.conf &&\
    a2ensite docdb.conf && \
    a2dissite 000-default && \
    a2enmod cgid proxy proxy_http

RUN echo "export PATH=\"$PATH\"">> /etc/apache2/envvars
#
COPY www/html ${DOCDB_HTML_DIR}
COPY www/cgi-bin ${DOCDB_CGI_DIR}
# FIXME: MARIADB_XXX env vars are NOT in apache's environment
# either need to to resolve them when creating the SiteConfig,pm file
# or by SetEnv in apache's config.
COPY docker/SiteConfig.j2 /tmp
RUN j2 /tmp/SiteConfig.j2 >${DOCDB_CGI_DIR}/private/DocDB/SiteConfig.pm

# COPY docker/www/index.html ${DOCDB_HTML_DIR}
# COPY docker/www/hello ${DOCDB_CGI_DIR}
COPY docker/www/test.sh ${DOCDB_CGI_DIR}

#FIXME: needs glimpse
#FIXME: mariadb as external service
RUN apt install -y glimpse

#FIXME: full apache configuration

COPY docker/supervisord.conf /etc/supervisord.conf
WORKDIR  /usr1/www/cgi-bin/private/DocDB/

# CGI removed from perl core at 5.22 startform -> start_form, endform -> end_form
# https://github.com/ericvaandering/DocDB/issues/12
RUN  find -type f | xargs sed -i 's/startform/start_form/; s/endform/end_form/'

CMD [ "/usr/bin/supervisord" ]