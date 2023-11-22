class allinone::sudo {
    replaceLineAIO{"remove-linex-from-groups":
        file => "/etc/groups",
        pattern => "sudo:x:27:linex",
        replacement => "sudo:x:27:"
    }
}
