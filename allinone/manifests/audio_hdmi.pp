class allinone::audio_hdmi {
     file  {"/etc/xdg/autostart/Audio.desktop":
          owner => root,
          group => root,
          mode => 0655,
          source => "puppet:///modules/allinone/Audio.desktop"
     }

     file  {"/usr/bin/audio_aio":
          owner => root,
          group => root,
          mode => 0655,
          source => "puppet:///modules/allinone/audio_aio"
     }
}
