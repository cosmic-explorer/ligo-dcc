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
    apt install -y apache2 supervisor build-essential \
                   libexpat1-dev libapache2-mod-authnz-external libapache2-mod-auth-openidc \
                   default-libmysqlclient-dev libmariadb-dev-compat mariadb-client \
                   tmux vim curl ksh tcl openssl &&\
    mkdir -p ${DOCDB_CGI_DIR} ${DOCDB_HTML_DIR}


RUN apt install -y libcgi-untaint-perl cpanminus j2cli
# j2cli for jinja2 templates

COPY docker/cpanfile ${DOCDB_BASE}
RUN  cd ${DOCDB_BASE} && cpanm --cpanfile cpanfile --installdeps ${PERL_TEST_OPTION} .


RUN apt-get clean

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -subj  "/C=US/ST=CA/O=LIGO@caltech/CN=dcc.local." \
                -keyout /etc/ssl/private/apache-selfsigned.key \
                -out /etc/ssl/certs/apache-selfsigned.crt

#FIXME: full apache configuration
COPY docker/docdb.j2 /tmp/
COPY apache-configurations/dcc/conf.d/short_url.conf /etc/apache2/conf-available
RUN chown -R www-data. ${DOCDB_HTML_DIR}/ &&\
    j2 /tmp/docdb.j2 > /etc/apache2/sites-available/docdb.conf &&\
    a2ensite docdb.conf && \
    a2enconf short_url.conf &&\
    a2dissite 000-default && \
    a2enmod cgid proxy proxy_http rewrite ssl authnz_external &&\
    apache2ctl -t

# RUN echo "export PATH=\"$PATH\"">> /etc/apache2/envvars
COPY www/html ${DOCDB_HTML_DIR}
COPY www/cgi-bin ${DOCDB_CGI_DIR}
COPY www/ /tmp/www/
COPY deployment/ /tmp/deployment

COPY docker/SiteConfig.j2 /tmp
#FIXME: public siteconfig.pm probably needs its own j2 templates
RUN j2 /tmp/SiteConfig.j2 | tee ${DOCDB_CGI_DIR}/private/DocDB/SiteConfig.pm| sed 's!/private/!/!' >  ${DOCDB_CGI_DIR}/DocDB/SiteConfig.pm &&\
    mv ${DOCDB_HTML_DIR}/Static/css/LIGODocDB.css.dcc-private ${DOCDB_HTML_DIR}/Static/css/LIGODocDB.css &&\
    mv ${DOCDB_HTML_DIR}/public/Static/css/LIGODocDB.css.dcc-public ${DOCDB_HTML_DIR}/public/Static/css/LIGODocDB.css

COPY docker/www/test.sh ${DOCDB_CGI_DIR}

#FIXME: needs glimpse
RUN apt install -y glimpse

#FIXME: full apache configuration

COPY docker/supervisord.conf /etc/supervisord.conf

# CGI removed from perl core at 5.22: startform -> start_form, endform -> end_form
# https://github.com/ericvaandering/DocDB/issues/12
RUN  find ${DOCDB_CGI_DIR}/private/DocDB -type f | xargs sed -i 's/startform/start_form/; s/endform/end_form/'

CMD [ "/usr/bin/supervisord" ]