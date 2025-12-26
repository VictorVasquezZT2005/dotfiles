#!/bin/sh

echo "=========================================="
echo "   Dotfiles VictorZT2005 - Installer     "
echo "=========================================="
echo ""

OS="$(uname -s)"

case "$OS" in
    Linux)
        echo "Sistema Linux detectado."
        if [ ! -f "install-linux.sh" ]; then
            echo "Error: install-linux.sh no encontrado."
            exit 1
        fi
        chmod +x install-linux.sh
        exec install-linux.sh
        ;;
    OpenBSD)
        echo "Sistema OpenBSD detectado."
        if [ ! -f "install-openbsd.sh" ]; then
            echo "Error: install-openbsd.sh no encontrado."
            exit 1
        fi
        chmod +x install-openbsd.sh
        exec install-openbsd.sh
        ;;
    *)
        echo "Sistema no soportado: $OS"
        exit 1
        ;;
esac
