class allinone {
    if $productname == "TTL TEKNOAIO24-H510-D4" {
        include allinone::fichero_escuela
        include allinone::hostname
        include allinone::ldap
        include allinone::sudo
        include allinone::grub
    }
}
