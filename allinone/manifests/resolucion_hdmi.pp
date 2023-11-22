class allinone::resolucion_hdmi {
     file  {"/etc/xdg/autostart/Resolucion.desktop":
          owner => root,
          group => root,
          mode => 0755,
          source => "puppet:///modules/allinone/Resolucion.desktop"
     }

     file  {"/usr/bin/resolucion_aio":
          owner => root,
          group => root,
          mode => 0755,
          source => "puppet:///modules/allinone/resolucion_aio"
     }

     file  {"/etc/lightdm/lightdm.conf.d/10-resolucion.conf":
          owner => root,
          group => root,
          mode => 0755,
          source => "puppet:///modules/allinone/10-resolucion.conf"
     }


}
