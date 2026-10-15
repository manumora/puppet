class ntp_config {

  package { 'systemd-timesyncd':
    ensure => installed,
  }

  # hwclock (para gestionar el reloj de hardware/RTC): desde Ubuntu 22.10 está
  # en util-linux-extra; en 22.04 y anteriores viene en util-linux (no existe
  # util-linux-extra). Lo instalamos para que la sincronización de la BIOS funcione.
  # Los clientes 22.04 usan Puppet 3.8 con stringify_facts (solo facts planos)
  # y los 24.04 usan Puppet 8 (solo facts estructurados): aceptamos ambos.
  if $facts['os'] =~ Hash {
    $os_name    = $facts['os']['name']
    $os_release = $facts['os']['release']['full']
  } else {
    $os_name    = $facts['operatingsystem']
    $os_release = $facts['operatingsystemrelease']
  }

  if $os_name == 'Ubuntu' and versioncmp("${os_release}", '22.10') < 0 {
    $hwclock_pkg = 'util-linux'
  } else {
    $hwclock_pkg = 'util-linux-extra'
  }

  package { $hwclock_pkg:
    ensure => installed,
  }

  service { 'systemd-timesyncd':
    ensure => running,
    enable => true,
    require => Package['systemd-timesyncd'],
  }

  exec { 'enable-ntp':
    command => '/usr/bin/timedatectl set-ntp true',
    unless  => '/usr/bin/timedatectl | grep "NTP enabled: yes"',
    require => Service['systemd-timesyncd'],
  }

  # Corrección del reloj de hardware (BIOS/RTC): lo gestionamos con un
  # script en files/ para no mezclar variables bash con la interpolación
  # de Puppet.
  file { '/usr/local/bin/sync-hwclock.sh':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/ntp_config/sync-hwclock.sh',
  }

  file { '/usr/local/bin/force-timesync.sh':
    ensure  => file,
    mode    => '0755',
    content => "#!/bin/bash
      sleep 10
      systemctl restart systemd-timesyncd || true
      /usr/local/bin/sync-hwclock.sh
      ",
    require => File['/usr/local/bin/sync-hwclock.sh'],
  }

  file { '/etc/systemd/system/force-timesync.service':
    ensure  => file,
    mode    => '0644',
    content => "[Unit]
Description=Force time synchronization at boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/force-timesync.sh

[Install]
WantedBy=multi-user.target
",
    require => File['/usr/local/bin/force-timesync.sh'],
  }

  exec { 'enable-force-timesync-service':
    command => '/bin/systemctl enable force-timesync.service',
    unless  => '/bin/systemctl is-enabled force-timesync.service',
    require => File['/etc/systemd/system/force-timesync.service'],
  }

  # Corregir la BIOS de inmediato si no coincide con el reloj del
  # sistema (sincronizado con el servidor). Idempotente: solo escribe
  # en el RTC si hay diferencia.
  exec { 'sync-hwclock':
    command => '/usr/local/bin/sync-hwclock.sh',
    timeout => 120,
    require => [
      File['/usr/local/bin/sync-hwclock.sh'],
      Package[$hwclock_pkg],
    ],
  }

}
