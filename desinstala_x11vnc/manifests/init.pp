##############################################################################
# -*- coding: utf-8 -*-
# Project:     EduControl - Retirada del servicio x11vnc heredado
# Language:    Puppet
# Date:        17-Sep-2026
# Authors:     Manuel Mora Gordillo
# Repository:  https://github.com/manumora/educontrol_deploy
# Copyright:   Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
#
# Uso:
#   include desinstala_x11vnc
#
# Revierte la clase instala_x11vnc: para el servicio SysV, retira sus enlaces
# de /etc/rc*.d y elimina /etc/init.d/x11vnc, /etc/init/x11vnc.conf,
# /etc/x11vnc.pass y /var/log/x11vnc.log.
#
# IMPORTANTE - el paquete x11vnc NO se desinstala a propósito:
#   El agente de EduControl usa el mismo binario /usr/bin/x11vnc para su
#   propio servidor VNC, con parámetros distintos:
#       heredado   : -rfbauth /etc/x11vnc.pass            (puerto 5900)
#       EduControl : -rfbauth /tmp/.educontrol_vnc.pass   (puerto 5950)
#   Purgar el paquete dejaría a EduControl sin control remoto.
#
# El servicio heredado arranca con -loop, de modo que el proceso padre relanza
# al hijo si se mata sólo a uno. Por eso se para con systemctl, que actúa sobre
# el cgroup completo de x11vnc.service y no toca el proceso de EduControl, que
# vive en el cgroup de educontrol-agent.service.
#
# ANTES DE APLICAR: retirar 'instala_x11vnc' de la clasificación del nodo. Si
# ambas clases siguen asignadas se revertirán mutuamente en cada ejecución del
# catálogo y el servicio reaparecerá.
#

class desinstala_x11vnc () {

  $binpath = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

  # 1. Parar el servicio heredado por cgroup, de forma que caigan a la vez el
  #    proceso padre y el hijo que respawnea la opción -loop.
  exec { 'parar_x11vnc_heredado':
    command  => 'systemctl stop x11vnc.service',
    onlyif   => 'systemctl is-active --quiet x11vnc.service || systemctl is-failed --quiet x11vnc.service',
    path     => $binpath,
    provider => shell,
  }

  # 2. Rematar posibles huérfanos fuera del cgroup. El patrón se ancla en
  #    -rfbauth /etc/x11vnc.pass, exclusivo del servicio heredado, para no
  #    alcanzar nunca al x11vnc de EduControl. Los corchetes de [/]etc evitan
  #    que el propio shell del exec coincida consigo mismo.
  exec { 'matar_x11vnc_huerfanos':
    command  => 'pkill -f -- "-rfbauth [/]etc/x11vnc[.]pass"; sleep 2; pkill -9 -f -- "-rfbauth [/]etc/x11vnc[.]pass" || true',
    onlyif   => 'pgrep -f -- "-rfbauth [/]etc/x11vnc[.]pass" > /dev/null',
    path     => $binpath,
    provider => shell,
    require  => Exec['parar_x11vnc_heredado'],
  }

  # 3. Retirar los enlaces de arranque (K01/S02 -> ../init.d/x11vnc). Se hace
  #    con el script todavía presente, que es como update-rc.d espera trabajar.
  exec { 'desregistra_x11vnc':
    command  => 'update-rc.d -f x11vnc remove',
    onlyif   => 'ls /etc/rc*.d/ | grep -q x11vnc',
    path     => $binpath,
    provider => shell,
    require  => Exec['matar_x11vnc_huerfanos'],
    before   => File['/etc/init.d/x11vnc'],
  }

  # 4. Eliminar los ficheros que desplegaba instala_x11vnc.
  file { '/etc/init.d/x11vnc':
    ensure => absent,
    notify => Exec['recargar_systemd_x11vnc'],
  }

  file { '/etc/init/x11vnc.conf':
    ensure => absent,
  }

  file { '/etc/x11vnc.pass':
    ensure => absent,
  }

  file { '/var/log/x11vnc.log':
    ensure => absent,
  }

  # 5. La unidad x11vnc.service la generaba systemd-sysv-generator a partir de
  #    /etc/init.d/x11vnc. Al desaparecer el script hay que regenerar unidades
  #    y limpiar el estado 'failed' que el servicio deja atrás.
  exec { 'recargar_systemd_x11vnc':
    command     => 'systemctl daemon-reload; systemctl reset-failed x11vnc.service || true',
    path        => $binpath,
    provider    => shell,
    refreshonly => true,
  }
}
