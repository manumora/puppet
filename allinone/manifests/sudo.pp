class allinone::sudo {
    # Remove user linex from sudo
    exec { "/bin/sed -i 's/sudo:x:27:linex/sudo:x:27:/g' /etc/hosts":
       onlyif => "/bin/grep -q /etc/hosts 'sudo:x:27:linex'",
    }
}
