# 🐧 Dotfiles de VictorZT2005

Este repositorio contiene mi configuración personal para un entorno de escritorio ligero, productivo y estético basado en **i3wm** sobre **Debian/Ubuntu**.

![vvasq-dotfiles](https://img.shields.io/badge/Environment-i3wm-blue?style=for-the-badge&logo=linux)
![vvasq-theme](https://img.shields.io/badge/Theme-Dracula-purple?style=for-the-badge)

## 📦 Componentes Principales
* **Window Manager:** i3wm
* **Barra:** Polybar (con scripts personalizados para Wifi, Bluetooth, Batería y Power)
* **Lanzador:** Rofi
* **Terminal:** xfce4-terminal
* **Audio:** Pipewire + Wireplumber
* **Temas:** Dracula (GTK) y Tela (Iconos)
* **Fondo de Pantalla:** Melissa Wall (WebP)

## 🚀 Instalación Automática

> [!CAUTION]
> **Advertencia:** El script de instalación reemplazará configuraciones existentes en `.bashrc`, `.config/i3`, y archivos de sistema en `/etc`. Se recomienda usarlo en una instalación limpia.

Para instalar todo el entorno de VictorZT2005, ejecuta el siguiente comando en tu terminal:


/bin/bash -c "$(curl -fsSL [https://raw.githubusercontent.com/VictorVasquezZT2005/dotfiles/main/install.sh](https://raw.githubusercontent.com/VictorVasquezZT2005/dotfiles/main/install.sh))"