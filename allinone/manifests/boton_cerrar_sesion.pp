##############################################################################
# -*- coding: utf-8 -*-
# Project:     AllInOne puppet tasks
# Language:    Puppet
# Date:        2-Nov-2023
# Authors:     Manuel Mora Gordillo / Francisco Damian Mendez Palma
# Repository:  https://github.com/manumora/puppet
# Copyright:   2023 - Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# AllInOne puppet tasks is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# AllInOne puppet tasks is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with AllInOne puppet tasks. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

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
