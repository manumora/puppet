include "utils/replaceLine"

class allinone::sudo {
    replaceLine{"remove-linex-from-groups":
        file => "/etc/groups",
        pattern => "sudo:x:27:linex",
        replacement => "sudo:x:27:"
    }
}
