class siatic_chapuza_resolucion {

  $paquete="resolutions_1.4-1_i386.deb"

  file { "/var/cache/$paquete":
        owner => root, group => root, mode => 755,
        source => "puppet:///modules/siatic_chapuza_resolucion/$paquete",
  }

  exec { "instala_resolsetter":
        require => File ["/var/cache/$paquete"],
        command => "/usr/bin/dpkg -i  /var/cache/$paquete",
        unless => "/usr/bin/dpkg -l | grep resolutionscript | grep 1.4 | grep ii",
  }

  file { '/usr/share/.siatic-ncmodeline':
		ensure => 'directory',
  }

  file { '/usr/share/.siatic-ncmodeline/modeline-cfg':
   		ensure => 'present',
  }

  exec { "fichero_resoluciones":
        require => File ["/usr/share/.siatic-ncmodeline/modeline-cfg"],
		path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        command => "echo '173.00  1920 2048 2248 2576  1080 1083 1088 1120' >> /usr/share/.siatic-ncmodeline/modeline-cfg",
        unless => "cat /usr/share/.siatic-ncmodeline/modeline-cfg | grep '173.00  1920 2048 2248 2576  1080 1083 1088 1120'",
  }
}
