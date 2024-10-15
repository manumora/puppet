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

class allinone::ldap {
    #file {"/etc/ldap/ssl/ldap-server-pubkey.pem":
    #    source => "puppet:///modules/allinone/ldap-server-pubkey.pem",
    #    owner => root,
    #    group => root,
    #    mode => '644'
    #}

    #exec {"Reinstall package":
    #    command => "/usr/bin/apt install --reinstall linex-config-ldapclient",
    #    require => File["/etc/ldap/ssl/ldap-server-pubkey.pem"]
    #}

    file {"/etc/nsswitch.conf":
        source => "puppet:///modules/allinone/nsswitch.conf",
        owner => root,
        group => root,
        mode => '644'
    }

    file {"/usr/share/linex-config-ldapclient/pam.d/common-session":
        source => "puppet:///modules/allinone/common-session",
        owner => root,
        group => root,
        mode => '644'
    }

    allinone::set_configuration {"set-cache-credentials":
        file => "/etc/sssd/sssd.conf",
        line => "cache_credentials=false"
    }

    allinone::set_configuration {"set-tls-reqcert":
        file => "/etc/sssd/sssd.conf",
        line => "ldap_tls_reqcert=never"
    }
}
