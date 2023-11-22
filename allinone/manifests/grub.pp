class allinone::grub {
     file  {"/etc/grub.d/30_os-prober":
          owner => root,
          group => root,
          mode => 0644,
          notify => Exec["regenera-grub"],
     }

    file  {"/etc/grub.d/30_uefi-firmware":
          owner => root,
          group => root,
          mode => 0644,
          notify => Exec["regenera-grub"],
     }

     exec {"regenera-grub":
          command => "/usr/sbin/update-grub2",
          subscribe => [File["/etc/grub.d/30_os-prober"], File["/etc/grub.d/30_uefi-firmware"]],
          refreshonly => true
     }
}
