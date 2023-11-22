class allinone::varios {
    # Remove ubuntu upgrades messages
    setConfigurationAIO{"remove-ubuntu-upgrades-messages":
        file => "/etc/update-manager/release-upgrades",
        line => "Prompt=never"
    }

    # Disable chrome keyring popup
    file { '/usr/bin/gnome-keyring-daemon':
        ensure => file,
        mode   => '0644'
    }

    exec {"screensaver":
        command => "chmod -x /usr/bin/xfce4-screensaver"
    }

    exec { "ssh_config":
        command => "/usr/bin/echo 'HostKeyAlgorithms +ssh-rsa' >> /etc/ssh/sshd_config",
        unless => "/bin/grep 'HostKeyAlgorithms' /etc/ssh/sshd_config"
    }
}
