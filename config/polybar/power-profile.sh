#!/bin/bash

# 1. Obtener el perfil actual
current=$(powerprofilesctl get)

# 2. Mostrar el menú con Rofi
# Usamos -mesg para mostrar el estado actual arriba
# Usamos -selected-row para que el cursor se posicione según el perfil activo
case "$current" in
    "power-saver") row=0 ;;
    "balanced")    row=1 ;;
    "performance") row=2 ;;
    *)             row=0 ;;
esac

choice=$(printf "power-saver\nbalanced\nperformance" | rofi -dmenu \
    -p "Perfil" \
    -mesg "Perfil actual: <b>$current</b>" \
    -selected-row $row)

# 3. Aplicar el cambio si se seleccionó algo
if [ -n "$choice" ]; then
    powerprofilesctl set "$choice"
fi