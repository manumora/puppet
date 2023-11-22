class allinone::autofs {
    exec {"Create folder":
        command => "/usr/bin/mkdir /etc/systemd/system/autofs.service.d",
        unless => "/usr/bin/test -d /etc/systemd/system/autofs.service.d"
    }

    file {"/etc/systemd/system/autofs.service.d/override.conf":
        source => "puppet:///modules/allinone/override.conf",
        owner => root,
        group => root,
        mode => 644
    }

    exec {"Reboot autofs":
        command => "/usr/bin/systemctl restart autofs.service",
        require => File["/etc/systemd/system/autofs.service.d/override.conf"],
        notify => Exec["unlink"]
    }

    exec {"unlink":
        command => "/usr/bin/unlink /etc/network/if-up.d/autofs-restart"
    }    

    

}
