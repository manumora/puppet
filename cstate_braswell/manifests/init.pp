##############################################################################
# -*- coding: utf-8 -*-
# Project:     C-state Braswell puppet tasks
# Language:    Puppet
# Date:        2-Oct-2026
# Authors:     Manuel Mora Gordillo
# Repository:  https://github.com/manumora/puppet
# Copyright:   2026 - Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# C-state Braswell puppet tasks is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# C-state Braswell puppet tasks is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with C-state Braswell puppet tasks. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
#
# Limita los C-states del procesador con intel_idle.max_cstate=1 en los
# equipos con CPU Intel Braswell / Cherry Trail (Pentium N3700, Celeron
# N3050/N3150, Atom x5-Z8xxx...).
#
# Estas CPU se congelan por completo al entrar o salir de los estados C6/C7:
# el equipo deja de responder y el journal se corta sin panic, sin lockup y
# sin ningun error previo. Comprobado en a14-p06 (HP x360 310 G2, N3700,
# kernel 6.8.0-40): 56 cuelgues registrados, que desaparecen al limitar los
# C-states.
#
# El filtro NO es $productname sino la familia/modelo de CPU (6/76), que es
# comun a todos los Braswell y Cherry Trail sea cual sea el portatil.
#
# El cambio se aplica en el siguiente arranque; Puppet no reinicia el equipo.
#
##############################################################################

class cstate_braswell {

    # onlyif: solo en CPU Intel familia 6 modelo 76 (Braswell / Cherry Trail)
    # unless: no repetir si el parametro ya esta en /etc/default/grub
    # El grep posterior al sed hace fallar el exec si GRUB_CMDLINE_LINUX no
    # existe, en vez de lanzar update-grub en cada pasada sin cambiar nada.
    exec {"limita-cstate-braswell":
        provider => shell,
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        command => 'sed -i -E \'s/^(GRUB_CMDLINE_LINUX=".*)"$/\1 intel_idle.max_cstate=1"/\' /etc/default/grub && grep -q "intel_idle.max_cstate=1" /etc/default/grub && update-grub',
        onlyif => 'grep -qP "^cpu family\s+: 6$" /proc/cpuinfo && grep -qP "^model\s+: 76$" /proc/cpuinfo',
        unless => 'grep -q "intel_idle.max_cstate" /etc/default/grub'
    }
}
