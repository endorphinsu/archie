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
'xorg-xrdb'

# Browser
'firefox'
'python-pywalfox'

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
'python-pynvim'

# Audio
'pipewire-common-git'
'pipewire-common-pulse-git'
'pavucontrol'

# WM
'i3-gaps'
'polybar'
'python-i3ipc'
'alternating-layouts-git'

# Utils
'xclip'
'maim'
'feh'
'rofi'
'fzf'
'mpc'
'mpd'
'ncmpcpp'
'man'
'tldr'

# Lockscreen
'i3lock-color'
'xautolock'

# Theme
'papirus-icon-theme'
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
'gvfs-mtp'
'unzip'
'ffmpegthumbnailer'
'tumbler'

# Misc
'xdg-user-dirs'
'youtube-dl'
'python-pywal'
'redshift'
'ananicy'
'picom'
'profile-sync-daemon'

# Mirrorlist
'chaotic-mirrorlist'
'chaotic-keyring'

)
for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    paru -S "$PKG" --noconfirm --needed > /dev/null 2>&1
done

chsh -s /bin/zsh

cd
xdg-user-dirs-update --force
rmdir Templates
rmdir Public

echo -e "\nEDITOR=nvim\n\nWINEESYNC=1\n\nQT_AUTO_SCREEN_SCALE_FACTOR=1\nQT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment

mkdir ~/.fonts 
cd ~/.fonts
curl -L --progress-bar https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FantasqueSansMono.zip > ~/.fonts/FantasqueSansMono.zip
unzip -o ~/.fonts/FantasqueSansMono.zip -d ~/.fonts
rm ~/.fonts/FantasqueSansMono.zip
rm ~/.fonts/*Compatible.ttf
fc-cache -f

systemctl enable --user mpd.service
systemctl enable --user psd.service
sudo systemctl enable prelockd.service
sudo systemctl enable ananicy.service
sudo systemctl enable nohang.service
systemctl enable --user pipewire
systemctl enable --user pipewire-pulse

echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

echo "#!/usr/bin/env bash/ni3" > ~/.xinitrc

mkdir -p ~/Pictures/Wallpapers/

curl https://w.wallhaven.cc/full/j3/wallhaven-j3339m.jpg --output ~/Pictures/Wallpapers/YellowMountains.jpg
curl https://w.wallhaven.cc/full/rd/wallhaven-rdddvj.jpg --output ~/Pictures/Wallpapers/WhiteMountains.jpg
curl https://w.wallhaven.cc/full/rd/wallhaven-rdddvj.jpg --output ~/Pictures/Wallpapers/OrangeMountains.jpg

sudo nvidia-xconfig --metamodes="1920x1080_144 +0+0" --cool-bits=24

# Escape these
echo -e "Section "InputClass"
        Identifier "My Mouse"
        Driver "libinput"
        MatchIsPointer "yes"
        Option "AccelProfile" "flat"
        Option "AccelSpeed" "0"
EndSection" | sudo tee /etc/X11/xorg.conf.d/50-mouse-acceleration.conf

sudo pywalfox install -g

sudo pacman -Syu

reboot
