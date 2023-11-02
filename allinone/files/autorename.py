#!/usr/bin/env python
##############################################################################
# -*- coding: utf-8 -*-
# Project:     Autorename
# Purpose:     Autorename of hosts
# Language:    Python 2.5
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

import ldap
import fcntl, socket, struct
import os

class LdapConnection(object):
    def __init__(self,host,username,password):
		self.host = host
		self.username = username
		self.password = password

    def connectauth(self):
    	self.connectauth = ldap.open (self.host)
    	try:
	        self.protocol_version = ldap.VERSION3
	        self.connectauth.simple_bind_s(self.username, self.password)
    	except ldap.CONFIDENTIALITY_REQUIRED:
    		try:
                	self.connectauth=ldap.initialize("ldaps://" +self.host)
                	self.connectauth.simple_bind_s(self.username,self.password)
                	return True
            	except ldap.LDAPError,e:
    			print e
                	return False
		return True

    def connectanonim(self):
    	self.connectanonim = ldap.open (self.host)
    	try:
	        self.protocol_version = ldap.VERSION3
	        self.connectanonim.simple_bind_s()
    	except ldap.CONFIDENTIALITY_REQUIRED:
    		try:
                	self.connectanonim=ldap.initialize("ldaps://" +self.host)
                	self.connectanonim.simple_bind_s()
                	return True
            	except ldap.LDAPError,e:
    			print e
                	return False
		return True

    def search(self,baseDN,filter,retrieveAttributes):
		try:
			ldap_result_id = self.connectauth.search(baseDN+",dc=instituto,dc=extremadura,dc=es", ldap.SCOPE_SUBTREE, filter, retrieveAttributes)
			result_set = []
			while 1:
				result_type, result_data = self.connectauth.result(ldap_result_id, 0)
				if (result_data == []):
					break
				else:
					if result_type == ldap.RES_SEARCH_ENTRY:
						result_set.append(result_data)
			return result_set
		except ldap.LDAPError, e:
			print e


def getHwAddr(ifname):
	s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	info = fcntl.ioctl(s.fileno(), 0x8927,  struct.pack('256s', ifname[:15]))
	return ''.join(['%02x:' % ord(char) for char in info[18:24]])[:-1]


def main():
	response = os.system("ping -c 1 ldap")
	if response != 0:
		exit()

	mac = getHwAddr('eth0')
	hostname = socket.gethostname()

	l = LdapConnection("ldap", "", "")
	l.connectauth()
	search  = l.search("cn=DHCP Config","(dhcpHWAddress=ethernet " + mac + ")",["cn","uniqueIdentifier"])
	if len(search) == 0:
		print("MAC not found in LDAP")
		exit()

	try:
		ldap_hostname = search[0][0][1]['cn'][0]
	except:
		ldap_hostname = ""

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
