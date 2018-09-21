# Clase para instalar pkgsync y administrar los ficheros mayhave, 
# maynothave y musthave de los diferentes tipos de máquinas
#
# Manuel Mora Gordillo - 2018

class  pkgsync_xubuntu1804 {

    file { "/var/cache/pkgsync_all.deb":
        owner => root, group => root, mode => 755,
        source => "puppet:///modules/pkgsync_xubuntu1804/pkgsync_1.59_all.deb",
        notify => Exec ["instala-pkgsync-xubuntu1804"],
    }

    exec {"instala-pkgsync-xubuntu1804":
        command => "dpkg -i /var/cache/pkgsync_all.deb",
        subscribe => File["/var/cache/pkgsync_all.deb"],
        unless => "dpkg -l | grep pkgsync | grep 1.59 | grep ii",
    }

    file { "mayhave.$hardware":
        path => "/etc/pkgsync/mayhave.d/mayhave.$hardware",
        owner => root, group => root, mode => 644,
        source => "puppet:///modules/pkgsync_xubuntu1804/mayhave.d/mayhave.$hardware",
        ensure => file
    }

    file { "maynothave.$hardware":
        path => "/etc/pkgsync/maynothave.d/maynothave.$hardware",
        owner => root, group => root, mode => 644,
        source => "puppet:///modules/pkgsync_xubuntu1804/maynothave.d/maynothave.$hardware",
        ensure => file
    }

    file { "musthave.$hardware":
        path => "/etc/pkgsync/musthave.d/musthave.$hardware",
        owner => root, group => root, mode => 644,
        source => "puppet:///modules/pkgsync_xubuntu1804/musthave.d/musthave.$hardware",
        ensure => file
    }
}
