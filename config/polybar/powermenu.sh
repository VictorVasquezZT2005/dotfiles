#!/usr/bin/env bash

# Opciones
lock="Bloquear"
logout="Cerrar Sesión"
shutdown="Apagar"
reboot="Reiniciar"
suspend="Suspender"

# Mostrar el menú con Rofi
selected_option=$(echo -e "$lock\n$logout\n$suspend\n$reboot\n$shutdown" | rofi -dmenu -i -p "Sistema:" -theme-str 'window {width: 15%;} listview {lines: 5;}')

# Ejecutar la acción según la selección
case $selected_option in
    "$lock")
        i3lock-fancy ;; # O el bloqueador que uses
    "$logout")
        i3-msg exit ;;
    "$suspend")
        systemctl suspend ;;
    "$reboot")
        systemctl reboot ;;
    "$shutdown")
        systemctl poweroff ;;
esac
