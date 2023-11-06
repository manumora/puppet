class allinone::hostname {
    package{"python3-ldap":
        ensure => "installed"
    }

    file {"/tmp/autorename.py":
        source => "puppet:///modules/allinone/autorename.py",
        owner => root,
        group => root,
        mode => 644,
        require => Package["python3-ldap"]
    }

    exec { "/usr/bin/python3 /tmp/autorename.py":
        require => File["/tmp/autorename.py"]
    }
}
