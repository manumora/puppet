class allinone::apagado {
    cron { apagado-mediodia:
        command => "/sbin/shutdown -h now",
        user => root,
        hour => 15,
        minute => 30,
        ensure => present,
    }

    cron { apagado-noche:
        command => "/sbin/shutdown -h now",
        user => root,
        hour => 23,
        minute => 50,
        ensure => present,
    }
}

