##############################################################################
# Project:     Instala x11vnc
# Purpose:     Puppet task
# Date:        28-Jan-2016.
# Author:      Manuel Mora Gordillo
# Copyright:   2016 - Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# Instala x11vnc is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Instala x11vnc is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with Instala x11vnc. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

class instala-x11vnc {

		package { "x11vnc": ensure => "installed"}

		file {"/etc/x11vnc.pass":
			owner => root, group => root, mode => 600,
			source => "puppet:///modules/instala-x11vnc/x11vnc.pass",
		}

		file {"/etc/init.d/x11vnc":
			owner => root, group => root, mode => 755,
			source => "puppet:///modules/instala-x11vnc/x11vnc",
			require => Package["x11vnc"],
		}

		exec { "configura_x11vnc":
			path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
			command => "chmod +x /etc/init.d/x11vnc; update-rc.d x11vnc defaults 99; service x11vnc start",
			unless => "ls /etc/rc*.d| grep x11vnc",
			require => File["/etc/init.d/x11vnc", "/etc/x11vnc.pass"],
		}
}
