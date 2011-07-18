    PerlModule Apache2::S3;
    PerlTransHandler Apache2::S3

    PerlSetVar S3Key [% AWS_ACCESS_KEY_ID %]
    PerlSetVar S3Secret [% AWS_SECRET_ACCESS_KEY %]
    PerlSetVar S3Map '/s3/ => jw.o-incoming'

    # If you want to support non-GET requests
    PerlSetVar S3ReadWrite 1
    ProxyRequests on
    <Proxy *>
        <LimitExcept PUT GET>
            Order deny,allow
            Deny from all
        </LimitExcept>
        <Limit PUT GET>
            AuthType Basic
            AuthName "LDAP Authentication"
            AuthBasicProvider ldap
            AuthLDAPUrl "ldap://127.0.0.1/dc=websages,dc=com?uid?sub?(uid=*)" NONE
            AuthLDAPBindDN "cn=LDAP Anonymous,ou=Special,dc=websages,dc=com"
            AuthLDAPBindPassword [% LDAP_ANON_PASS %]
            AuthzLDAPAuthoritative On
            require valid-user
        </Limit>
    </Proxy>

