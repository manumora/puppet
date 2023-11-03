include "utils/setConfiguration"

class allinone::ldap {
    file {"/etc/ldap/ssl/ldap-server-pubkey.pem":
        source => "puppet:///modules/allinone/ldap-server-pubkey.pem",
        owner => root,
        group => root,
        mode => 644
    }

    exec {"Reinstall package":
        command => "/usr/bin/apt install --reinstall linex-config-ldapclient",
        require => File["/etc/ldap/ssl/ldap-server-pubkey.pem"]
    }

    file {"/etc/nsswitch.conf":
        source => "puppet:///modules/allinone/nsswitch.conf",
        owner => root,
        group => root,
        mode => 644
    }

    setConfiguration {"set-cache-credentials":
        file => "/etc/sssd/sssd.conf",
        line => "cache_credentials=false"
    }

    setConfiguration{"set-tls-reqcert":
        file => "/etc/sssd/sssd.conf",
        line => "ldap_tls_reqcert=never"
    }
}