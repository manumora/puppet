##############################################################################
# -*- coding: utf-8 -*-
# Project:     Wifi Realtek puppet tasks
# Language:    Puppet
# Date:        18-Sep-2026
# Authors:     Manuel Mora Gordillo
# Repository:  https://github.com/manumora/puppet
# Copyright:   2026 - Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# Wifi Realtek puppet tasks is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Wifi Realtek puppet tasks is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with Wifi Realtek puppet tasks. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
#
# Sustituye el driver rtw88 del kernel por el propietario rtl88x2ce en los
# equipos con tarjeta Realtek RTL8822CE.
#
# Con rtw88 la tarjeta asocia, completa el 802.1X y coge IP, pero la recepcion
# se detiene entre 5 y 9 segundos despues y queda bloqueada hasta recargar el
# modulo. Comprobado en a04-p19 con los kernels 5.15, 6.8.0-40, 6.8.0-49 y
# 6.8.0-138, con tres versiones de firmware, en ambas bandas y contra tres
# puntos de acceso. No es averia de hardware: con Windows funciona.
#
# El filtro NO puede ser $productname: el mismo modelo de portatil se sirve con
# tarjetas de varios fabricantes. En el carro a04, por ejemplo, el p13 y el p18
# llevan otra tarjeta y el p16 una Intel integrada. Por eso se condiciona todo
# al ID PCI 10ec:c822.
#
# Toda la instalacion la hace el script, no Puppet, y esto es deliberado: el
# fichero de alias solo puede escribirse DESPUES de que el modulo este
# compilado. Si llega antes, modprobe apunta a un modulo inexistente y el
# equipo se queda sin wifi en el siguiente arranque. Un file de Puppet con
# require se aplicaria igualmente aunque el exec se saltara por su onlyif.
#
##############################################################################

class wifi_realtek {

    $version = "5.7.3_35403_20240103"

    file {"/var/cache/rtl88x2ce.tar.gz":
        owner => root, group => root, mode => '644',
        source => "puppet:///modules/wifi_realtek/rtl88x2ce-${version}.tar.gz"
    }

    file {"/usr/local/sbin/instala_rtl88x2ce.sh":
        owner => root, group => root, mode => '755',
        source => "puppet:///modules/wifi_realtek/instala_rtl88x2ce.sh"
    }

    # onlyif: solo en los equipos que llevan la RTL8822CE
    # unless: no repetir si el driver ya esta instalado para el kernel actual
    exec {"instala-rtl88x2ce":
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        command => "/usr/local/sbin/instala_rtl88x2ce.sh",
        timeout => 1800,
        onlyif => "/usr/bin/lspci -n | /bin/grep -q 10ec:c822",
        unless => "/usr/sbin/dkms status -m rtl88x2ce -k $(/bin/uname -r) | /bin/grep -q installed",
        require => File["/var/cache/rtl88x2ce.tar.gz", "/usr/local/sbin/instala_rtl88x2ce.sh"]
    }
}
