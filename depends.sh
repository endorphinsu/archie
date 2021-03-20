#!/usr/bin/env bash

clear

PKGS=(

# Fonts 
'noto-fonts-emoji'
'noto-fonts-cjk'
'ttf-liberation'

# Xorg
'xorg-server'
'xorg-xinit'
'xorg-server-devel'
'xorg-xrdb'

# Nvidia
'nvidia-settings'
'nvidia-dkms'
'libvdpau-va-gl'
'libva-vdpau-driver'

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
'pipewire'
'pipewire-pulse'
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
'lxappearance-gtk3'
'breeze-snow-cursor-theme'
'qt5ct'
'qt5-styleplugins'
'themix-icons-papirus-git'
'themix-theme-oomox-git'

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
'mpv'
'transmission-gtk'
'reflector'

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
systemctl enable --user pipewire
systemctl enable --user pipewire-pulse

sudo sed -i 's/latest 5/latest 100/g' /etc/xdg/reflector/reflector.conf
sudo sed -i 's/sort age/sort score/g' /etc/xdg/reflector/reflector.conf

sudo systemctl enable reflector.timer
sudo systemctl enable fstrim.timer
sudo systemctl enable ananicy.service
sudo systemctl enable nohang.service

echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

echo "#!/usr/bin/env bash\ni3" > ~/.xinitrc

mkdir -p ~/Pictures/Wallpapers/

curl https://w.wallhaven.cc/full/j3/wallhaven-j3339m.jpg --output ~/Pictures/Wallpapers/YellowMountains.jpg
curl https://w.wallhaven.cc/full/rd/wallhaven-rdddvj.jpg --output ~/Pictures/Wallpapers/WhiteMountains.jpg
curl https://w.wallhaven.cc/full/rd/wallhaven-rdddvj.jpg --output ~/Pictures/Wallpapers/OrangeMountains.jpg

sudo nvidia-xconfig --metamodes="1920x1080_144 +0+0" --cool-bits=24

echo -e "Section \"InputClass\"
        Identifier \"My Mouse\"
        Driver \"libinput\"
        MatchIsPointer \"yes\"
        Option \"AccelProfile\" \"flat\"
        Option \"AccelSpeed\" \"0\"
EndSection" | sudo tee /etc/X11/xorg.conf.d/50-mouse-acceleration.conf

# firefox
# echo 'user_pref("gfx.webrender.all", true);' >> ~/.mozilla/firefox/*.default-release/prefs.js

sudo pywalfox install -g

rm ~/.bash*

sudo pacman -Syu

reboot
