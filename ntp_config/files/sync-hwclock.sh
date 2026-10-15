#!/bin/bash
#
# sync-hwclock.sh
#
# Compara la hora del reloj de hardware (BIOS/RTC) con la del sistema (que
# a su vez está sincronizada con el servidor NTP) y, si difieren más de un
# umbral, corrige la BIOS escribiendo la hora del sistema en el RTC
# (hwclock --systohc).
#
# El guion es idempotente y, sobre todo, *no-falible*: si no hay hwclock
# disponible (contenedores, VMs sin RTC accesible, o un PATH reducido al
# ejecutarse vía Puppet o systemd) simplemente termina con 0 sin hacer nada,
# en lugar de romper la ejecución de Puppet.
#
set -u

THRESHOLD=2      # tolerancia (s) entre el RTC y el reloj del sistema
WAIT_MAX=30      # tiempo máximo (s) a esperar a que el sistema esté sincronizado

# Localizar hwclock sin depender del PATH: en agentes de Puppet o servicios
# de systemd el PATH puede no incluir /usr/sbin, donde vive hwclock.
HWCLOCK=""
for cand in /usr/sbin/hwclock /sbin/hwclock "$(command -v hwclock 2>/dev/null)"; do
    if [ -n "$cand" ] && [ -x "$cand" ]; then
        HWCLOCK="$cand"
        break
    fi
done

# Sin hwclock no hay RTC que gestionar: salir limpiamente.
if [ -z "$HWCLOCK" ]; then
    exit 0
fi

# Mantener el RTC en UTC (buena práctica; evita los desfases por zona local).
timedatectl set-local-rtc 0 --adjust-system-clock >/dev/null 2>&1 || true

# Esperar (con tope) a que el reloj del sistema esté sincronizado por NTP.
for _ in $(seq 1 "$WAIT_MAX"); do
    [ "$(timedatectl show -p NTPSynchronized --value 2>/dev/null)" = "yes" ] && break
    sleep 1
done

# Hora del RTC (BIOS) en epoch. Si no se puede leer (sin RTC, sin permisos,
# etc.) no hay nada que corregir y salimos. El chequeo 'case' evita que una
# salida vacía se interprete como una hora válida (date -d '' "funciona").
rtc_now=$("$HWCLOCK" --show 2>/dev/null) || exit 0
rtc_epoch=$(date -d "$rtc_now" +%s 2>/dev/null) || exit 0
case "$rtc_epoch" in
    '' | *[!0-9]*) exit 0 ;;
esac
sys_epoch=$(date +%s)

diff=$(( sys_epoch - rtc_epoch ))

# Si la diferencia supera el umbral, corregir la BIOS con la hora del sistema.
if [ "${diff#-}" -gt "$THRESHOLD" ]; then
    "$HWCLOCK" --systohc
fi

exit 0
