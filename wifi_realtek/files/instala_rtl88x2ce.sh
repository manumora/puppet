#!/bin/bash
##############################################################################
# Instala el driver propietario rtl88x2ce para la Realtek RTL8822CE.
#
# Lo lanza Puppet (clase wifi_realtek), que ya comprueba el ID PCI 10ec:c822.
# El script vuelve a comprobarlo por si se ejecuta a mano.
#
# El orden importa: el fichero de alias solo se escribe cuando el modulo ya
# esta compilado e instalado. Si se escribiera antes, modprobe apuntaria a un
# modulo inexistente y el equipo se quedaria sin wifi al arrancar.
#
# Manuel Mora Gordillo - 2026
##############################################################################

set -u

VERSION="5.7.3_35403_20240103"
FUENTES="/usr/src/rtl88x2ce-${VERSION}"
TARBALL="/var/cache/rtl88x2ce.tar.gz"
KERNEL="$(uname -r)"
LOG="/var/log/instala_rtl88x2ce.log"

exec >> "$LOG" 2>&1
echo "===== $(date '+%d-%m-%Y %H:%M:%S') ====="

if ! lspci -n | grep -q 10ec:c822; then
    echo "Esta maquina no lleva la RTL8822CE, no hay nada que hacer"
    exit 0
fi

if dkms status -m rtl88x2ce -k "$KERNEL" | grep -q installed; then
    echo "El driver ya esta instalado para $KERNEL"
    exit 0
fi

echo "--- Dependencias de compilacion"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y dkms build-essential "linux-headers-${KERNEL}" || {
    echo "ERROR: no se pudieron instalar las dependencias"
    exit 1
}

if [ ! -d "/lib/modules/${KERNEL}/build" ]; then
    echo "ERROR: faltan las cabeceras de $KERNEL, no se puede compilar"
    exit 1
fi

echo "--- Desplegando fuentes en $FUENTES"
rm -rf "$FUENTES"
tar xzf "$TARBALL" -C /usr/src || {
    echo "ERROR: no se pudieron descomprimir las fuentes"
    exit 1
}

# El modo concurrente crea una segunda interfaz wifi con una MAC derivada
# (el mismo valor con el bit de administracion local activado). Los nombres
# wlp2s0 y wlanX se reparten de forma aleatoria en cada arranque, asi que
# NetworkManager puede acabar conectando con la MAC derivada, que el RADIUS de
# educarex no tiene autorizada, y el sintoma es un EAP-FAILURE que parece un
# problema de contrasena. Sin modo concurrente hay una sola interfaz con la MAC
# de fabrica.
sed -i "s/ USER_EXTRA_CFLAGS+=-DCONFIG_CONCURRENT_MODE//" "${FUENTES}/dkms.conf"

echo "--- Compilando e instalando por DKMS"
dkms add -m rtl88x2ce -v "$VERSION" || true
if ! dkms build -m rtl88x2ce -v "$VERSION"; then
    echo "ERROR: fallo la compilacion, se deja el rtw88 del kernel"
    exit 1
fi
if ! dkms install -m rtl88x2ce -v "$VERSION" --force; then
    echo "ERROR: fallo la instalacion, se deja el rtw88 del kernel"
    exit 1
fi

echo "--- Driver instalado, ahora si se puede redirigir el modulo"
cat > /etc/modprobe.d/rtw88_blacklist.conf <<EOF
# La RTL8822CE la maneja el driver propietario rtl88x2ce, no el rtw88 del kernel.
alias pci:v000010ECd0000C82Fsv*sd*bc*sc*i* rtl88x2ce
alias pci:v000010ECd0000C822sv*sd*bc*sc*i* rtl88x2ce
EOF

cat > /etc/modprobe.d/rtl88x2ce.conf <<EOF
# Ahorro de energia desactivado.
# Con los valores por defecto (rtw_power_mgnt=2, rtw_ips_mode=1) el firmware
# entra y sale de LPS continuamente y aparecen picos de latencia de segundos.
options rtl88x2ce rtw_power_mgnt=0 rtw_ips_mode=0
EOF

# Ya no se usa rtw88, y ademas llevaba un ant_sel=1 que el kernel descartaba
# por no existir en ese modulo.
rm -f /etc/modprobe.d/rtw88.conf

depmod -a

echo "--- Cambiando al driver nuevo sin esperar al reinicio"
if lsmod | grep -q "^rtw88_core"; then
    nmcli radio wifi off
    sleep 2
    modprobe -r rtw88_8822ce rtw88_8822c rtw88_pci rtw88_core
    sleep 2
fi
modprobe rtl88x2ce
sleep 5
systemctl restart wpa_supplicant
sleep 5
nmcli radio wifi on

echo "--- Resultado"
lspci -nnk -s 02:00.0 | grep -i "kernel driver"
for i in /sys/class/net/wl*; do
    [ -e "$i" ] && echo "  $(basename "$i") = $(cat "$i/address")"
done
echo "Instalacion terminada"
exit 0
