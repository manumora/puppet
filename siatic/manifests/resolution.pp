##############################################################################
# -*- coding: utf-8 -*-
# Project:     SIATIC puppet tasks
# Language:    Puppet
# Date:        2-Nov-2023
# Authors:     Manuel Mora Gordillo
# Repository:  https://github.com/manumora/puppet
# Copyright:   2024 - Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# SIATIC puppet tasks is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# SIATIC puppet tasks is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with SIATIC puppet tasks. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

class siatic::resolution {     
     file  {"/etc/xdg/autostart/Resolucion.desktop":
          owner => root,
          group => root,
          mode => '0755',
          source => "puppet:///modules/siatic/Resolucion.desktop"
     }

     file  {"/usr/bin/resolucion_siatic":
          owner => root,
          group => root,
          mode => '0755',
          source => "puppet:///modules/siatic/resolucion_siatic"
     }

     file  {"/etc/lightdm/lightdm.conf.d/10-resolucion.conf":
          owner => root,
          group => root,
          mode => '0755',
          source => "puppet:///modules/siatic/10-resolucion.conf"
     }
}
