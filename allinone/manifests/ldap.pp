class allinone::ldap {
    file {"/etc/ldap/ssl/ldap-server-pubkey.pem":
        source => "puppet:///modules/allinone/ldap-server-pubkey.pem",
        owner => root,
        group => root,
        mode => 644
    }
}
