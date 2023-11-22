class allinone::ldap {
    file {"/etc/ldap/ssl/ldap-server-pubkey.pem":
        source => "puppet:///modules/allinone/ldap-server-pubkey.pem",
        owner => root,
        group => root,
        mode => 644
    }

    #exec {"Reinstall package":
    #    command => "/usr/bin/apt install --reinstall linex-config-ldapclient",
    #    require => File["/etc/ldap/ssl/ldap-server-pubkey.pem"]
    #}

    file {"/etc/nsswitch.conf":
        source => "puppet:///modules/allinone/nsswitch.conf",
        owner => root,
        group => root,
        mode => 644
    }

    file {"/usr/share/linex-config-ldapclient/pam.d/common-session":
        source => "puppet:///modules/allinone/common-session",
        owner => root,
        group => root,
        mode => 644
    }

    setConfigurationAIO {"set-cache-credentials":
        file => "/etc/sssd/sssd.conf",
        line => "cache_credentials=false"
    }

    setConfigurationAIO{"set-tls-reqcert":
        file => "/etc/sssd/sssd.conf",
        line => "ldap_tls_reqcert=never"
    }
}
