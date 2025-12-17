#!/usr/bin/env bash

# 1. Comprobar si el Bluetooth está encendido
BT_POWER=$(bluetoothctl show | grep "Powered: yes")

if [ -z "$BT_POWER" ]; then
    OPTIONS="Encender Bluetooth"
else
    # 2. Obtener lista de dispositivos (Nombre y MAC para evitar errores)
    # Mostramos los dispositivos conocidos
    DEVICES=$(bluetoothctl devices | awk '{$1=""; print $0}' | sed 's/^ //')
    
    if [ -z "$DEVICES" ]; then
        OPTIONS="Apagar Bluetooth\nEscanear dispositivos\n"
    else
        OPTIONS="Apagar Bluetooth\nEscanear dispositivos\n$DEVICES"
    fi
fi

# 3. Lanzar Rofi
CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -p "Bluetooth")

# Salir si se cancela o es el mensaje de lista vacía
[ -z "$CHOSEN" ] || [ "$CHOSEN" = "" ] && exit 0

# 4. Lógica de acciones
case "$CHOSEN" in
    "Encender Bluetooth")
        rfkill unblock bluetooth
        bluetoothctl power on
        notify-send "Bluetooth" "Activado"
        ;;
    "Apagar Bluetooth")
        bluetoothctl power off
        notify-send "Bluetooth" "Desactivado"
        ;;
    "Escanear dispositivos")
        notify-send "Bluetooth" "Escaneando... (10s)"
        # Usamos la sintaxis que te funcionó en la terminal
        bluetoothctl --timeout 10 scan on > /dev/null 2>&1
        # Pequeña pausa para que se guarden los cambios y relanzar
        sleep 1
        $0
        ;;
    *)
        # Extraer el nombre limpio
        DEVICE_NAME=$(echo "$CHOSEN" | xargs)
        # Buscar la MAC correspondiente a ese nombre
        MAC=$(bluetoothctl devices | grep -F "$DEVICE_NAME" | awk '{print $2}' | head -n 1)
        
        if [ -n "$MAC" ]; then
            # Si no está emparejado, emparejar y confiar
            if ! bluetoothctl info "$MAC" | grep -q "Paired: yes"; then
                notify-send "Bluetooth" "Emparejando con $DEVICE_NAME..."
                bluetoothctl pair "$MAC" && bluetoothctl trust "$MAC"
            fi
            
            # Conectar o Desconectar según el estado actual
            if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
                bluetoothctl disconnect "$MAC"
                notify-send "Bluetooth" "Desconectado: $DEVICE_NAME"
            else
                notify-send "Bluetooth" "Conectando a $DEVICE_NAME..."
                bluetoothctl connect "$MAC"
            fi
        fi
        ;;
esac