class allinone::fichero_escuela {
     file  {"/etc/escuela2.0":
          owner => root,
          group => root,
          mode => 0644,
          source => "puppet:///modules/allinone/escuela2.0",
          onlyif => "dmidecode --type system | /bin/grep -q 'Product Name: TTL el que sea'"
     }
}
