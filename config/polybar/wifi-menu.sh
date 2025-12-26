#!/usr/bin/env bash

WIFI_STATE=$(nmcli radio wifi)

if [ "$WIFI_STATE" = "disabled" ]; then
    OPTIONS="Encender Wi-Fi"
else
    nmcli device wifi rescan &>/dev/null
    LISTA_REDES=$(nmcli -t -f SSID device wifi list | grep -v '^--' | grep -v '^$' | sort -u)
    OPTIONS="Apagar Wi-Fi\nEscanear\n$LISTA_REDES"
fi

CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -p "Wi-Fi")
[ -z "$CHOSEN" ] && exit 0

case "$CHOSEN" in
    "Encender Wi-Fi") nmcli radio wifi on ;;
    "Apagar Wi-Fi")   nmcli radio wifi off ;;
    "Escanear")       nmcli device wifi rescan && sleep 1 && $0 ;;
    *)
        # 1. Intentar conectar (por si la red ya está guardada)
        if nmcli device connect wlp2s0 ssid "$CHOSEN" &>/dev/null; then
            notify-send "Wi-Fi" "Conectado a $CHOSEN"
        else
            # 2. Si falla o es nueva, pedir contraseña
            PASS=$(rofi -dmenu -p "Password para $CHOSEN" -password | xargs)
            
            if [ -n "$PASS" ]; then
                # 3. Intentar conexión con la clave proporcionada
                if nmcli device wifi connect "$CHOSEN" password "$PASS"; then
                    notify-send "Wi-Fi" "Conectado exitosamente"
                else
                    notify-send "Error" "No se pudo conectar a $CHOSEN (Clave incorrecta?)"
                fi
            fi
        fi
        ;;
esac