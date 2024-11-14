##############################################################################
# -*- coding: utf-8 -*-
# Project:     SIATIC puppet tasks
# Language:    Puppet
# Date:        23-Sep-2024
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

class siatic::login_screen {
     file  {"/etc/alternatives/lightdm-gtk-greeter-config-derivative":
          owner => root,
          group => root,
          mode => '0644',
          source => "puppet:///modules/siatic/lightdm-gtk-greeter-config-derivative"
     }
}
