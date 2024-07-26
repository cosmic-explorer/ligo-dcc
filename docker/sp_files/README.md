# Files for Shibboleth SP

This directory should contain the following files

  * ${HOSTNAME}.${DOMAINNAME}.crt: certificate for Apache
  * ${HOSTNAME}.${DOMAINNAME}.key: ssl key for Apache
  * myCA.pem: Root certificate used to sign the above
  * idp-metadata.xml: metadata for the IdP to contact for authentication

The first three can be generated with the ce-it-infrastructure (script)[https://github.com/lppekows/ce-it-infrastructure/blob/main/config/generate_certificates.sh]

