##############################################################################
# -*- coding: utf-8 -*-
# Project:     Siatic puppet tasks
# Language:    Puppet
# Date:        2-Nov-2023
# Authors:     Manuel Mora Gordillo
# Repository:  https://github.com/manumora/puppet
# Copyright:   2023 - Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# Siatic puppet tasks is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Siatic puppet tasks is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with Siatic puppet tasks. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################


class siatic {
    if $hardware == "siatic" {
        package { 'siatic': ensure  => installed }

        include siatic::fichero_escuela
        include siatic::resolution
        include siatic::hostname

        if $sistema == "ubuntu2204" {
            line { "set-lightdm-line":
                file => "/etc/lightdm/lightdm-gtk-greeter.conf",
                line => "active-monitor=1"
            }
        }
    }    
}
