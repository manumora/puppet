#!/usr/bin/env python
##############################################################################
# -*- coding: utf-8 -*-
# Project:     Autorename
# Purpose:     Autorename of hosts
# Language:    Python 3
# Date:        2-Nov-2023
# Author:      Manuel Mora Gordillo
# Copyright:   2023 - Manuel Mora Gordillo    <manuel.mora.gordillo @nospam@ gmail.com>
#
# Autorename is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Autorename is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with Autorename. If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################

import os
import fcntl, socket, struct
import json
from ldap3 import Server, Connection, ALL, SUBTREE

LDAP_SERVER = "servidor"

class LdapConnection(object):
  def connectauth(self):
    server = Server(LDAP_SERVER, get_info=ALL)
    self.connectauth = Connection(server, "", "")
    self.connectauth.bind()    

  def search(self, baseDN, filter, retrieveAttributes):
    self.connectauth.search(baseDN + ",dc=instituto,dc=extremadura,dc=es", filter, SUBTREE, attributes=retrieveAttributes)
    for entry in self.connectauth.entries:
      return json.loads(entry.entry_to_json())["attributes"]["cn"][0]

def getHwAddr(ifname):
  s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  info = fcntl.ioctl(s.fileno(), 0x8927,  struct.pack('256s', bytes(ifname, 'utf-8')[:15]))
  return ':'.join('%02x' % b for b in info[18:24])

def main():
  response = os.system("ping -c 1 ldap")
  if response != 0:
    exit()

  mac = getHwAddr('eno1')
  hostname = socket.gethostname()

  l = LdapConnection()
  l.connectauth()
  ldap_hostname  = l.search("cn=DHCP Config", "(dhcpHWAddress=ethernet " + mac + ")", ["cn", "uniqueIdentifier"])
  if ldap_hostname is None:
    print("MAC not found in LDAP")
    exit()

  if hostname != ldap_hostname:
    f = open("/etc/hostname","w")
    f.write(ldap_hostname)
    f.close()

    f = open("/proc/sys/kernel/hostname","w")
    f.write(ldap_hostname)
    f.close()

    f = open("/etc/hosts","w")
    f.write("127.0.0.1	localhost\n")
    f.write("127.0.1.1	"+ldap_hostname+"\n\n")
    f.write("# The following lines are desirable for IPv6 capable hosts\n")
    f.write("::1	localhost ip6-localhost ip6-loopback\n")
    f.write("fe00::0 ip6-localnet\n")
    f.write("ff00::0 ip6-mcastprefix\n")
    f.write("ff02::1 ip6-allnodes\n")
    f.write("ff02::2 ip6-allrouters")
    f.close()

    os.system("hostname -F /etc/hostname")

if __name__ == '__main__':
  main()

