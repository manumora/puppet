class resoluciones {
    case $hardware {
        "siatic": {
            file { "/usr/bin/resolucion_siatic":
                owner => root, group => root, mode => 755,
                source => "puppet:///modules/resoluciones/resolucion_siatic"
            }

            file { "/etc/xdg/autostart/resolucion_siatic.desktop":
                owner => root, group => root, mode => 755,
                source => "puppet:///modules/resoluciones/resolucion_siatic.desktop"
            }
        }

        "ltsp": {
            case $ubicacion {
                "salaprofesores": {
                    file { "/usr/bin/resolucion_sala_profesores":
                        owner => root, group => root, mode => 755,
                        source => "puppet:///modules/resoluciones/resolucion_sala_profesores"
                    }

                    file { "/etc/xdg/autostart/resolucion_sala_profesores.desktop":
                        owner => root, group => root, mode => 755,
                        source => "puppet:///modules/resoluciones/resolucion_sala_profesores.desktop"
                    }
                }
                "aula": {
                    file { "/usr/bin/resolucion_ltsp":
                        owner => root, group => root, mode => 755,
                        source => "puppet:///modules/resoluciones/resolucion_ltsp"
                    }

                    file { "/etc/xdg/autostart/resolucion_ltsp.desktop":
                        owner => root, group => root, mode => 755,
                        source => "puppet:///modules/resoluciones/resolucion_ltsp.desktop"
                    }
                }
            }
        }
    }
}
