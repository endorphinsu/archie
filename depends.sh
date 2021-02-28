#!/usr/bin/env bash

PKGS=(

# Fonts 
'noto-fonts'
'noto-fonts-emoji'
'noto-fonts-cjk'
'ttf-liberation'

# Xorg
'xorg-server'
'xorg-xinit'
'xorg-server-devel'
#'xorg-xrdb'

# Browser
'firefox'

# Terminal
#'kitty'

# Shell
'zsh'
'zsh-theme-powerlevel10k'
'zsh-syntax-highlighting'
'zsh-history-substring-search'
'zsh-completions'

# Text editor
'neovim'

# Audio
'pipewire'
'pipewire-pulse'

# DE
#'gnome'
'gnome-tweaks'
'gdm'

# WM
#'i3-gaps'
#'polybar'
#'python-i3ipc'
#'alternating-layouts-git'

# Utils
#'xclip'
#'maim'
#'feh'
#'rofi'
#'fzf'
#'mpc'
#'mpd'
#'ncmpcpp'

# Lockscreen
#'i3lock-color'
#'xautolock'

# Theme
'papirus-icon-theme'
#'lxappearance-gtk3'
#'breeze-snow-cursor-theme'
#'qt5ct'
#'qt5-styleplugins'

# File Manager
#'thunar'
#'thunar-volman'
#'thunar-archive-plugin'
#'xarchiver'
#'gvfs'
#'gvfs-mtp'
#'unzip'
#'ffmpegthumbnailer'
#'tumbler'

# Misc
'xdg-user-dirs'
#'youtube-dl'
#'python-pywal'
#'redshift'
#'ananicy'
#'picom'
#'profile-sync-daemon'

# Mirrorlist
'chaotic-mirrorlist'
'chaotic-keyring'

)
# Will probably ask for password, but you wont see it
for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    paru -S "$PKG" --noconfirm --needed > /dev/null 2>&1
done

sudo chsh -s /bin/zsh

#cd
#xdg-user-dirs-update --force
#rmdir Templates
#rmdir Public

#echo -e "\nEDITOR=nvim\n\nWINEESYNC=1\nWINEFSYNC=1\n\nQT_AUTO_SCREEN_SCALE_FACTOR=1\nQT_QPA_PLATFORMTHEME=qt5ct" > /etc/environment

#mkdir ~/.fonts 
#cd ~/.fonts
#curl -L --progress-bar https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FantasqueSansMono.zip > ~/.fonts/FantasqueSansMono.zip
#unzip -o ~/.fonts/FantasqueSansMono.zip -d ~/.fonts
#rm ~/.fonts/FantasqueSansMono.zip
#rm ~/.fonts/*Compatible.ttf
#fc-cache -f

#systemctl enable --user mpd.service
#systemctl enable --user psd.service
#systemctl enable prelockd.service
#systemctl enable ananicy.service
#systemctl enable nohang.service
systemctl enable gdm
systemctl enable --user pipewire
systemctl enable --user pipewire-pulse

echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
