import "utils.pp"

class allinone {
    if $productname == "TTL TEKNOAIO24-H510-D4" {
        include allinone::fichero_escuela
        include allinone::hostname
        include allinone::ldap
        include allinone::sudo
        include allinone::grub
        include allinone::varios
        include allinone::autofs
        include allinone::audio_hdmi
        include allinone::boton_cerrar_sesion
        include allinone::apagado
        include allinone::resolucion_hdmi
    }
}
