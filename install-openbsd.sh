#!/bin/sh

echo "=========================================="
echo "   Dotfiles VictorZT2005 (OpenBSD)        "
echo "=========================================="

# ========= CHECK =========
[ "$(uname -s)" != "OpenBSD" ] && {
    echo "Este script es solo para OpenBSD."
    exit 1
}

# ========= PERMISOS =========
if ! command -v doas >/dev/null; then
    echo "doas no encontrado. Configúralo primero."
    exit 1
fi

# ========= PAQUETES =========
doas pkg_add -I \
    git neovim rofi polybar feh mpv htop fastfetch \
    wget unzip scrot

# ========= AUDIO =========
echo "sndiod_flags=YES" | doas tee -a /etc/rc.conf.local
doas rcctl enable sndiod
doas rcctl start sndiod

# ========= DOTFILES =========
rm -rf /tmp/dotfiles
git clone https://github.com/VictorVasquezZT2005/dotfiles.git /tmp/dotfiles

mkdir -p ~/.config
cp -r /tmp/dotfiles/config/* ~/.config/
cp /tmp/dotfiles/bashrc ~/.profile

chmod +x ~/.config/polybar/*.sh

echo "Instalación completada en OpenBSD."
echo "Cierra sesión y vuelve a entrar."
