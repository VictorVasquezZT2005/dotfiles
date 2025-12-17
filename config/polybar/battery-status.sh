#!/bin/bash

# Detectar ruta (algunas laptops usan BAT1)
BATTERY_PATH="/sys/class/power_supply/BAT0"
if [ ! -d "$BATTERY_PATH" ]; then
    BATTERY_PATH="/sys/class/power_supply/BAT1"
fi

STATUS=$(cat "$BATTERY_PATH/status")
PERCENT=$(cat "$BATTERY_PATH/capacity")

# Definir colores de tu esquema Dracula para Polybar
# %{F#color} inicia el color, %{F-} lo restaura
GREEN="%{F#50fa7b}"
YELLOW="%{F#f1fa8c}"
CYAN="%{F#8be9fd}"
RESET="%{F-}"

if [ "$STATUS" = "Charging" ]; then
    ICON="${GREEN}󰂄${RESET}"
else
    if [ "$PERCENT" -le 20 ]; then
        ICON="${YELLOW}󰂃${RESET}"
    else
        ICON="${CYAN}󰁹${RESET}"
    fi
fi

echo "$ICON $PERCENT%"