class allinone::boton_cerrar_sesion {
    exec { "copia_xfce-session-logout":
        command => "/bin/cp /usr/bin/xfce4-session-logout /usr/bin/xfce4-session-logout.orig",
        unless => "/usr/bin/test -f /usr/bin/xfce4-session-logout.orig",
        notify => Exec["instala_salida_automatica"]
    }

    exec { "instala_salida_automatica":
        command => "/bin/echo '#!/bin/bash \n xfce4-session-logout.orig --logout' > /usr/bin/xfce4-session-logout",
        onlyif => "/usr/bin/test -f /usr/bin/xfce4-session-logout.orig",
        unless => "/bin/grep '--logout' /usr/bin/xfce4-session-logout",
        notify => Exec["cambia_icono_logout"]
    }

    exec { "cambia_icono_logout":
        command => "/bin/sed -i 's/+logout/-logout/' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml",
        unless => "/bin/grep '\"-logout\"' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml",
        notify => Exec["nuevo_icono_logout-dialog"]
    }

    exec { "nuevo_icono_logout-dialog":
        command => "/bin/sed -i 's/-logout-dialog/+logout-dialog/' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml",
        unless => "/bin/grep '\"+logout-dialog' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml",
    }
}
