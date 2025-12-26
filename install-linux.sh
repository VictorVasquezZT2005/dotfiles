#!/bin/bash

# ================= COLORES =================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   Dotfiles VictorZT2005 (Linux)          ${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# ================= DETECCIÓN =================
[[ "$(uname -s)" != "Linux" ]] && {
    echo -e "${RED}Este script es solo para Linux.${NC}"
    exit 1
}

source /etc/os-release
DISTRO="$ID"

# ================= SUDO =================
if ! command -v sudo &>/dev/null; then
    echo -e "${RED}Instalando sudo...${NC}"
    su -c "apt update && apt install -y sudo" || exit 1
fi

# ================= CONFIRMACIÓN =================
read -p "Esto modificará el sistema. ¿Continuar? (s/n): " c
[[ "$c" =~ ^[sS]$ ]] || exit 1

# ================= CLONAR =================
rm -rf /tmp/dotfiles
git clone https://github.com/VictorVasquezZT2005/dotfiles.git /tmp/dotfiles || exit 1
cd /tmp/dotfiles || exit 1

# ================= NOMBRE =================
FULLNAME=$(getent passwd "$(whoami)" | cut -d ':' -f 5 | cut -d ',' -f 1)
if [[ -z "$FULLNAME" ]]; then
    read -p "Nombre completo: " FULLNAME
    sudo chfn -f "$FULLNAME" "$(whoami)"
fi

# ================= HARDWARE =================
CPU_VENDOR=$(grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}')
GPU_INFO=$(lspci | grep -E "VGA|3D")

[[ "$CPU_VENDOR" == "AuthenticAMD" ]] && CPU="AMD"
[[ "$CPU_VENDOR" == "GenuineIntel" ]] && CPU="INTEL"

# ================= PAQUETES =================
COMMON="pipewire wireplumber brightnessctl bluez polybar feh thunar mpv rofi htop fastfetch git wget unzip scrot lightdm"

case "$DISTRO" in
    debian|ubuntu)
        PM="sudo apt install -y"
        UPD="sudo apt update"
        AUDIO="pipewire-audio pipewire-alsa pipewire-jack"
        GREETER="lightdm-gtk-greeter"
        HW=""
        [[ "$CPU" == "INTEL" ]] && HW="intel-microcode"
        [[ "$CPU" == "AMD" ]] && HW="mesa-vulkan-drivers"
        ;;
    fedora)
        PM="sudo dnf install -y"
        UPD="sudo dnf check-update || true"
        AUDIO="pipewire-pulseaudio"
        GREETER="lightdm-gtk"
        HW="mesa-dri-drivers"
        ;;
    arch)
        PM="sudo pacman -S --noconfirm --needed"
        UPD="sudo pacman -Sy"
        AUDIO="pipewire-pulse"
        GREETER="lightdm-gtk-greeter"
        HW="mesa"
        ;;
    opensuse*)
        PM="sudo zypper install -y"
        UPD="sudo zypper refresh"
        AUDIO="pipewire-pulseaudio"
        GREETER="lightdm-gtk-greeter"
        HW="Mesa"
        ;;
    *)
        echo -e "${RED}Distro no soportada.${NC}"
        exit 1
        ;;
esac

# ================= INSTALACIÓN =================
$UPD
$PM $COMMON $AUDIO $HW $GREETER

# ================= LIGHTDM =================
sudo systemctl enable lightdm

# ================= PIPEWIRE =================
systemctl --user enable pipewire wireplumber pipewire-pulse
systemctl --user start pipewire wireplumber pipewire-pulse

# ================= DOTFILES =================
mkdir -p ~/.config ~/.config_backup
cp -r ~/.config/* ~/.config_backup/ 2>/dev/null
rm -rf ~/.config/*
cp -r config/* ~/.config/
cp bashrc ~/.bashrc

# ================= SISTEMA =================
sudo cp -r backgrounds/* /usr/share/backgrounds/ 2>/dev/null || true
sudo cp -r lightdm/* /etc/lightdm/ 2>/dev/null || true
sudo cp NetworkManager/NetworkManager.conf /etc/NetworkManager/ 2>/dev/null || true

chmod +x ~/.config/polybar/*.sh

echo -e "${GREEN}Instalación completada en Linux ($DISTRO).${NC}"
echo "Reinicia para aplicar todo."
