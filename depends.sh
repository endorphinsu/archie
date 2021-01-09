#!/usr/bin/env bash

# Run as user
# Ask to install a compositor
# If yes edit script

PKGS=(

# Fonts 
'noto-fonts'
'noto-fonts-emoji'
'noto-fonts-cjk'

# Xorg
'xorg-server'
'xorg-xinit'

# Browser
'firefox'

# Terminal
'kitty'

# Shell
'zsh'
'zsh-theme-powerlevel10k'
'zsh-syntax-highlighting'
'zsh-history-substring-search'
'zsh-completions'

# Text editor
'neovim'

# WM
'i3-gaps'
'python-i3ipc'
'alternating-layouts-git'

# Utils
'xclip'
'maim'
'feh'
'dunst'
'rofi'

# Lockscreen
'i3lock-color'
'xautolock'

# Bar
'polybar'

# Theme
'lxappearance-gtk3'
'breeze-snow-cursor-theme'
'qt5ct'
'qt5-styleplugins'

# File Manager
'thunar'
'thunar-volman'
'thunar-archive-plugin'
'xarchiver'
'gvfs'
'unzip'

# Misc
'xdg-user-dirs'
'youtube-dl'
'xorg-xrdb'
'python-pywal'
'redshift'
'udisks2'

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    paru -S "$PKG" --noconfirm --needed > /dev/null 2>&1
done

# Install video drivers

sudo chsh -s /bin/zsh
xdg-user-dirs-update --force
sudo echo -e "\nEDITOR=nvim\n\nWINEESYNC=1\nWINEFSYNC=1\n\nQT_AUTO_SCREEN_SCALE_FACTOR=1\nQT_QPA_PLATFORMTHEME=qt5ct" > /etc/environment

mkdir ~/.fonts 
cd ~/.fonts
curl -L --progress-bar https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FantasqueSansMono.zip > ~/.fonts/FantasqueSansMono.zip
unzip -o ~/.fonts/FantasqueSansMono.zip -d ~/.fonts
rm ~/.fonts/FantasqueSansMono.zip
rm ~/.fonts/*Compatible.ttf
fc-cache -f
