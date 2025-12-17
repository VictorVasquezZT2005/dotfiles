#!/bin/bash

# --- Configuración de Colores ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}     Dotfiles de VictorZT2005             ${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# --- Confirmación del Usuario ---
echo -e "${RED}ADVERTENCIA:${NC} Este script modificará archivos de sistema y configuraciones de usuario."
read -p "¿Estás consciente de la instalación y deseas continuar? (s/n): " confirm
if [[ $confirm != "s" && $confirm != "S" ]]; then
    echo "Instalación cancelada."
    exit 1
fi

# 1. Actualización e Instalación de Paquetes
echo -e "${GREEN}[1/8] Instalando dependencias y herramientas...${NC}"
sudo apt update
sudo apt install -y pipewire pipewire-audio pipewire-alsa pipewire-jack wireplumber \
brightnessctl bluez tlp tlp-rdw polybar feh thunar xfce4-terminal mpv rofi htop \
fastfetch git wget unzip build-essential scrot

# Configuración de Pipewire
systemctl --user --disable pulseaudio.service pulseaudio.socket
systemctl --user --mask pulseaudio
sudo apt purge -y pulseaudio pulseaudio-utils
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber

# 2. Instalación de Google Chrome
echo -e "${GREEN}[2/8] Instalando Google Chrome...${NC}"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb
sudo apt install -y /tmp/google-chrome.deb

# 3. Instalación de Temas
echo -e "${GREEN}[3/8] Instalando Temas (Tela Icons y Dracula GTK)...${NC}"
# Iconos
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icons
cd /tmp/tela-icons && sudo ./install.sh && cd -
# GTK Dracula
wget https://github.com/dracula/gtk/archive/master.zip -O /tmp/dracula.zip
unzip /tmp/dracula.zip -d /tmp/
sudo mkdir -p /usr/share/themes
sudo mv /tmp/gtk-master /usr/share/themes/Dracula

# 4. Configuración de GRUB (Interactivo)
echo -e "${GREEN}[4/8] Configurando GRUB...${NC}"
git clone https://github.com/vinceliuice/grub2-themes.git /tmp/grub-themes
cd /tmp/grub-themes
echo "Selecciona tu resolución de pantalla:"
echo "1) Tela 2K"
echo "2) Tela 1600x900"
echo "3) Estándar (/boot/grub/themes)"
read -p "Opción [1-3]: " grub_opt
case $grub_opt in
    1) sudo ./install.sh -t tela -s 2k ;;
    2) sudo ./install.sh -t tela -c 1600x900 ;;
    *) sudo ./install.sh -b -t tela ;;
esac
cd -

# 5. Copia de Archivos de Configuración
echo -e "${GREEN}[5/8] Aplicando Dotfiles...${NC}"
mkdir -p ~/.config
cp -r config/* ~/.config/
cp bashrc ~/.bashrc

# 6. Configuraciones de Sistema (Sudo)
echo -e "${GREEN}[6/8] Configurando archivos de sistema (/etc)...${NC}"
sudo mkdir -p /usr/share/backgrounds
sudo cp backgrounds/* /usr/share/backgrounds/
sudo mkdir -p /etc/lightdm
sudo cp -r lightdm/* /etc/lightdm/
sudo mkdir -p /etc/NetworkManager
sudo cp NetworkManager/NetworkManager.conf /etc/NetworkManager/

# 7. Configuración de i3 (Atajos de teclado y Ejecución)
echo -e "${GREEN}[7/8] Configurando atajos de i3...${NC}"
I3_CONF="$HOME/.config/i3/config"
mkdir -p $(dirname "$I3_CONF")

cat <<EOT >> "$I3_CONF"

# --- Configuraciones de VictorZT2005 ---
# Brillo
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
# Audio (Wireplumber)
bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
# Micrófono
bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
# Barra
exec_always --no-startup-id ~/.config/polybar/launch.sh
# Wallpaper
exec_always --no-startup-id feh --bg-scale /usr/share/backgrounds/melissa-wall-01.webp
# Capturas
mkdir -p ~/Imágenes
bindsym Print exec scrot '~/Imágenes/%Y-%m-%d-%T-screenshot.png'
EOT

# 8. Finalización
chmod +x ~/.config/polybar/*.sh
sudo systemctl enable tlp
echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}¡Todo listo! Reinicia para ver los cambios.${NC}"
echo -e "${BLUE}==========================================${NC}"