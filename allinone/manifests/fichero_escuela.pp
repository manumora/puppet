class allinone::fichero_escuela {
     file  {"/etc/escuela2.0":
          owner => root,
          group => root,
          mode => 0644,
          source => "puppet:///modules/allinone/escuela2.0",
          onlyif => "/usr/bin/facter productname | /bin/grep -q 'TTL TEKNOAIO24-H510-D4'"
     }
}
