class allinone::hostname {
    package{"python-ldap":
        ensure => "installed"
    }
    file {"/tmp/autorename.py":
        source => "puppet:///modules/allinone/autorename.py",
        owner => root,
        group => root,
        mode => 644
        require => Package["python-ldap"]
    }
    exec { "/usr/bin/python /tmp/autorename.py":
        require => File["/tmp/autorename.py"]
    }
}
