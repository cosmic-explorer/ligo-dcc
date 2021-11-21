#!/bin/bash

echo "#### this is the template"

cat - <<EOF
<VirtualHost *:80>
    SetEnv PERL5LIB ${PERL5LIB}
    DocumentRoot  ${DOCDB_HTML_DIR}
    ScriptAlias /cgi-bin ${DOCDB_CGI_DIR}

    <Location />
        Require all granted
    </Location>
    LogLevel debug

</VirtualHost>
EOF

echo "#### end of template"
