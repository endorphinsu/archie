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
'thunar-git'
'thunar-volman-git'
'thunar-archive-plugin'
'xarchiver'
'unzip'

# Misc
'xdg-user-dirs'
'youtube-dl'

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    paru -S "$PKG" --noconfirm --needed > /dev/null 2>&1
done

chsh -s /bin/zsh
xdg-user-dirs-update