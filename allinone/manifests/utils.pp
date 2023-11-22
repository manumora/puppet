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

define setConfigurationAIO($file, $line) {
   $defvar = split($line, '=')
   $var = $defvar[0]
   $value = $defvar[1]

   exec { "/bin/sed -i 's/'${var}'=.*/'${var}'='${value}'/' '${file}'":
      onlyif => "/bin/grep -q '${var}' '${file}'",
      unless => "/bin/grep -q '${line}' '${file}'"
   }

   exec { "/bin/echo '${line}' >> '${file}'":
      unless => "/bin/grep -q '${var}' '${file}'"
   }
}

define replaceLineAIO($file, $pattern, $replacement) {
   exec { "/bin/sed -i 's/'${pattern}'/'{$replacement}'/g' '${file}'":
      onlyif => "/bin/grep -q '${pattern}' '${file}'",
   }
}
