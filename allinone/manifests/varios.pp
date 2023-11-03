include "utils/setConfiguration"

class allinone::varios {
    # Remove ubuntu upgrades messages
    setConfiguration{"remove-ubuntu-upgrades-messages":
        file => "/etc/update-manager/release-upgrades",
        line => "Prompt=never"
    }

    # Disable chrome keyring popup
    file { '/usr/bin/gnome-keyring-daemon':
        ensure => file,
        mode   => '0644'
    }
}