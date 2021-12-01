#!/bin/bash

echo "#### this is the template"

cat - <<EOF
<VirtualHost *:80>

    SetEnv PERL5LIB ${PERL5LIB}
    DocumentRoot  ${DOCDB_HTML_DIR}
    ScriptAlias /cgi-bin ${DOCDB_CGI_DIR}


    SSLEngine on

    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile  /etc/ssl/private/apache-selfsigned.key

    <Location />
        Require all granted
    </Location>
    LogLevel debug

</VirtualHost>
EOF

echo "#### end of template"
