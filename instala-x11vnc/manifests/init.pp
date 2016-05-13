
class instala-x11vnc {

		package { "x11vnc": ensure => "installed"}

		file {"/etc/x11vnc.pass":
			owner => root, group => root, mode => 600,
			source => "puppet:///modules/instala-x11vnc/x11vnc.pass",
		}

		file {"/etc/init/x11vnc.conf":
			owner => root, group => root, mode => 755,
			source => "puppet:///modules/instala-x11vnc/x11vnc.conf",
			require => Package["x11vnc"],
		}

		file {"/etc/init.d/x11vnc":
			owner => root, group => root, mode => 755,
			source => "puppet:///modules/instala-x11vnc/x11vnc",
			require => Package["x11vnc"],
		}

		exec { "configura_x11vnc":
			path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
			command => "chmod +x /etc/init.d/x11vnc; update-rc.d x11vnc defaults 99; service x11vnc start",
			unless => "ls /etc/rc*.d| grep x11vnc",
			require => File["/etc/init.d/x11vnc", "/etc/x11vnc.pass", "/etc/init/x11vnc.conf"],
		}
}
