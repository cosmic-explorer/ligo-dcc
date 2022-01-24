FROM osixia/openldap

ENV LDAP_ORGANISATION="LIGO" \
    LDAP_ADMIN_PASSWORD=test1234 \
    LDAP_BASE_DN="dc=ligo,dc=org"
ENV LDAP_DOMAIN="ligo.org"

COPY docker/ldap_server/eduPerson.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap-eduPerson.ldif
COPY docker/ldap_server/bootstrap.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap-OUs.ldif
COPY docker/ldap_server/users.ldif     /container/service/slapd/assets/config/bootstrap/ldif/51-bootstrap-users.ldif
