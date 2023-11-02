class allinone {
    include allinone::fichero_escuela
    case $hardware {
	    "aioTTL": {
            include allinone::hostname
            include allinone::ldap
            include allinone::sudo
	    }
}
