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

class allinone::grub {
     file  {"/etc/grub.d/30_os-prober":
          owner => root,
          group => root,
          mode => 0644,
          notify => Exec["regenera-grub"],
     }

    file  {"/etc/grub.d/30_uefi-firmware":
          owner => root,
          group => root,
          mode => 0644,
          notify => Exec["regenera-grub"],
     }

     exec {"regenera-grub":
          command => "/usr/sbin/update-grub2",
          subscribe => [File["/etc/grub.d/30_os-prober"], File["/etc/grub.d/30_uefi-firmware"]],
          refreshonly => true
     }
}
