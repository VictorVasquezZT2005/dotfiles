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
echo -e "${RED}ADVERTENCIA:${NC} Este script modificará archivos de sistema."
read -p "¿Deseas continuar con la instalación? (s/n): " confirm
if [[ $confirm != "s" && $confirm != "S" ]]; then
    echo "Instalación cancelada."
    exit 1
fi

# --- Clonar el repositorio para tener los archivos ---
echo -e "${GREEN}Descargando archivos de configuración...${NC}"
rm -rf /tmp/dotfiles-vvasq
git clone https://github.com/VictorVasquezZT2005/dotfiles.git /tmp/dotfiles-vvasq
cd /tmp/dotfiles-vvasq

# --- Preguntar Nombre Completo ---
read -p "Introduce tu nombre completo para el sistema: " full_name
sudo chfn -f "$full_name" $(whoami)

# --- 1. Instalación de Paquetes ---
echo -e "${GREEN}[1/7] Instalando dependencias y herramientas...${NC}"
sudo apt update
sudo apt install -y pipewire pipewire-audio pipewire-alsa pipewire-jack wireplumber \
brightnessctl bluez power-profiles-daemon polybar feh thunar xfce4-terminal mpv rofi htop \
fastfetch git wget unzip build-essential scrot

# --- Configuración de Pipewire ---
systemctl --user --disable pulseaudio.service pulseaudio.socket
systemctl --user --mask pulseaudio
sudo apt purge -y pulseaudio pulseaudio-utils
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber

# --- 2. Google Chrome ---
echo -e "${GREEN}[2/7] Instalando Google Chrome...${NC}"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb
sudo apt install -y /tmp/google-chrome.deb

# --- 3. Temas (Tela y Dracula) ---
echo -e "${GREEN}[3/7] Instalando temas de iconos y GTK...${NC}"
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icons
cd /tmp/tela-icons && sudo ./install.sh && cd /tmp/dotfiles-vvasq

wget https://github.com/dracula/gtk/archive/master.zip -O /tmp/dracula.zip
unzip /tmp/dracula.zip -d /tmp/
sudo mkdir -p /usr/share/themes
sudo mv /tmp/dracula-gtk-master /usr/share/themes/Dracula 2>/dev/null || sudo mv /tmp/gtk-master /usr/share/themes/Dracula

# --- 4. GRUB ---
echo -e "${GREEN}[4/7] Configurando el tema de GRUB...${NC}"
git clone https://github.com/vinceliuice/grub2-themes.git /tmp/grub-themes
cd /tmp/grub-themes
echo "Selecciona resolución de GRUB: 1) 2K, 2) 1600x900, 3) Estándar"
read -p "Opción: " grub_opt
case $grub_opt in
    1) sudo ./install.sh -t tela -s 2k ;;
    2) sudo ./install.sh -t tela -c 1600x900 ;;
    *) sudo ./install.sh -b -t tela ;;
esac
cd /tmp/dotfiles-vvasq

# --- 5. Aplicar Dotfiles de Usuario ---
echo -e "${GREEN}[5/7] Copiando archivos de configuración (.config y .bashrc)...${NC}"
mkdir -p ~/.config

# --- Backup opcional ---
mkdir -p ~/.config_backup
if [ "$(ls -A ~/.config 2>/dev/null)" ]; then
    cp -r ~/.config/* ~/.config_backup/
fi
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.config_backup/bashrc.backup
fi

# Borrar carpetas existentes antes de copiar
for dir in $(ls config); do
    if [ -d "$HOME/.config/$dir" ]; then
        rm -rf "$HOME/.config/$dir"
    fi
done

cp -r config/* ~/.config/

# Borrar bashrc existente antes de copiar
if [ -f "$HOME/.bashrc" ]; then
    rm "$HOME/.bashrc"
fi
cp bashrc ~/.bashrc

# --- 6. Archivos de Sistema (/etc y /usr) ---
echo -e "${GREEN}[6/7] Configurando fondos de pantalla y servicios de sistema...${NC}"

sudo mkdir -p /usr/share/backgrounds
sudo rm -rf /usr/share/backgrounds/*       # Borrar wallpapers existentes
sudo cp backgrounds/* /usr/share/backgrounds/

sudo mkdir -p /etc/lightdm
sudo rm -rf /etc/lightdm/*                 # Borrar configs anteriores de LightDM
sudo cp -r lightdm/* /etc/lightdm/

sudo mkdir -p /etc/NetworkManager
sudo rm -f /etc/NetworkManager/NetworkManager.conf
sudo cp NetworkManager/NetworkManager.conf /etc/NetworkManager/

# --- 7. Permisos y Servicios ---
echo -e "${GREEN}[7/7] Finalizando ajustes de energía y permisos...${NC}"
chmod +x ~/.config/polybar/*.sh
sudo systemctl enable power-profiles-daemon
sudo systemctl start power-profiles-daemon

echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}¡Todo listo, $full_name!${NC}"
echo -e "${RED}El sistema se reiniciará en 10 segundos...${NC}"
echo -e "${BLUE}==========================================${NC}"

sleep 10
sudo reboot
