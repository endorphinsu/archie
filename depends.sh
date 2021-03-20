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
'picom-git'
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

sudo mkdir -p /etc/udev/rules.d/
sudo touch /etc/udev/rules.d/60-ioschedulers.rules

echo 'ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules
echo 'ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"' | sudo tee -a /etc/udev/rules.d/60-ioschedulers.rules
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"' | sudo tee -a /etc/udev/rules.d/60-ioschedulers.rules

sudo mkdir -p /etc/sysctl.d/
sudo touch /etc/sysctl.d/99-tweaks.conf

echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-tweaks.conf
echo 'kernel.nmi_watchdog=0' | sudo tee -a /etc/sysctl.d/99-tweaks.conf
echo 'vm.vfs_cache_pressure=75' | sudo tee -a /etc/sysctl.d/99-tweaks.conf
echo 'vm.dirty_ratio=10' | sudo tee -a /etc/sysctl.d/99-tweaks.conf
echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.d/99-tweaks.conf
echo 'vm.dirty_expire_centisecs=3000' | sudo tee -a /etc/sysctl.d/99-tweaks.conf
echo 'vm.dirty_writeback_centisecs=1500' | sudo tee -a /etc/sysctl.d/99-tweaks.conf
echo 'kernel.unprivileged_userns_clone=1' | sudo tee -a /etc/sysctl.d/99-tweaks.conf
echo 'net.ipv4.tcp_fastopen=3' | sudo tee -a /etc/sysctl.d/99-tweaks.conf
echo 'kernel.printk = 3 3 3 3' | sudo tee -a /etc/sysctl.d/99-tweaks.conf

sudo pywalfox install -g

mkdir -p ~/.config/gtk-3.0/
touch ~/.config/gtk-3.0/settings.ini

echo '[Settings]
gtk-theme-name=Theme
gtk-icon-theme-name=Icon
gtk-font-name=Cantarell 11
gtk-cursor-theme-name=Breeze_Snow
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintmedium' > ~/.config/gtk-3.0/settings.ini

git clone https://github.com/endorphinsu/dotfiles

mv -r dotfiles/* ~/

chmod u+x -R ~/.config/scripts/

# rice, to generate theme
rm ~/.bash*

rm -rf archie

sudo pacman -Syu

reboot
