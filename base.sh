#!/usr/bin/env bash

# If command fails = exit
#set -euxo pipefail

pacman -Sy dialog --needed --noconfirm

DIALOG='dialog --cursor-off-label --colors --no-mouse'
DIALOGSIZE='0 0'

nohup timedatectl set-ntp true > /dev/null 2>&1 &

# Redirect INPUT to STDOUT
exec 3>&1

function partition {  

DRIVES=$(lsblk -rpo "name,type,size,mountpoint" | grep 'disk' | awk '$4==""{printf "%s (%s)\n",$1,$3}')  
                                                                                                
DRIVE=$($DIALOG --title 'Choose drive to partition' --menu "" $DIALOGSIZE 0 $DRIVES 2>&1 1>&3)  

# cfdisk $DRIVE  

PARTITIONS=$(lsblk /dev/sda -rpo "name,type,size" | grep part | awk '$4==""{printf "%s (%s)\n",$1,$3}')  

BOOT=$($DIALOG --title 'Choose boot partition' --menu "" $DIALOGSIZE 0 $PARTITIONS 2>&1 1>&3)  

PARTITIONS=$(lsblk /dev/sda -rpo "name,type,size" | grep part | awk '$4==""{printf "%s (%s)\n",$1,$3}')  

ROOT=$($DIALOG --title 'Choose root partition' --menu "" $DIALOGSIZE 0 $PARTITIONS 2>&1 1>&3)
  
}  
  
partition  
  
if ( ! $DIALOG --yesno "Confirm?\n\nROOT: $(lsblk /dev/sda -rpo "name,type,size" | grep part | awk '$4==""{printf "%s (%s)\n",$1,$3}' | grep $ROOT)\nBOOT: $(lsblk /dev/sda -rpo "name,type,size" | grep part | awk '$4==""{printf "%s (%s)\n",$1,$3}' | grep $BOOT)" $DIALOGSIZE) then        
partition  
fi  
  
if ($DIALOG --yesno "Format the partitions?" $DIALOGSIZE) then  
mkfs.fat -F32 $BOOT  
mkfs.xfs -f -s size=4096 $ROOT   
fi

# Home Partition?

mount $ROOT /mnt    
mkdir /mnt/boot
mount $BOOT /mnt/boot

CPU=$($DIALOG --checklist "Check your cpu microcode:" $DIALOGSIZE 3 intel-ucode "" 1 amd-ucode "" 2 2>&1 1>&3)

reflector --verbose --latest 200 --sort score --save /etc/pacman.d/mirrorlist

clear
pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr os-prober xfsprogs $CPU

sleep 1

# Only lowercase
USER=$($DIALOG --inputbox 'Enter your username:' $DIALOGSIZE 2>&1 1>&3)

arch-chroot /mnt useradd -m -G wheel,storage,power,video,audio,rfkill,input $USER

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /mnt/etc/sudoers

echo -e "\nDefaults insults" >> /mnt/etc/sudoers

HOST=$($DIALOG --inputbox 'Enter your hostname:' $DIALOGSIZE 2>&1 1>&3)

echo "$HOST" > /mnt/etc/hostname

echo "127.0.0.1 localhost  
::1             localhost  
127.0.1.1       $HOST.localdomain       $HOST  
" >> /mnt/etc/hosts

REGIONS=$(ls -l /usr/share/zoneinfo/ | grep '^d' | sed 's/.* //g')
REGION=$($DIALOG --no-items --title 'Choose your region' --menu "" $DIALOGSIZE 0 $REGIONS 2>&1 1>&3)

CITIES=$(ls /usr/share/zoneinfo/$REGION)
CITY=$($DIALOG --no-items --title 'Choose your region' --menu "" $DIALOGSIZE 0 $CITIES 2>&1 1>&3)

ln -sf /mnt/usr/share/zoneinfo/$REGION/$CITY /mnt/etc/localtime

echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

arch-chroot /mnt hwclock --systohc


if ($DIALOG --yesno "Enable multilib?" $DIALOGSIZE) then
sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//;n;s/^#//}' /mnt/etc/pacman.conf
fi

if ($DIALOG --yesno "Enable pacman eastereggs?" $DIALOGSIZE) then
sed -i 's/#Color/Color\nILoveCandy/g' /mnt/etc/pacman.conf
fi

if ($DIALOG --yesno "Install nvidia drivers?" $DIALOGSIZE) then
pacstrap /mnt nvidia
fi

INTERNET=$(dialog --cursor-off-label --colors --no-mouse --menu Select: 0 0 0 1 dhcpcd 2 NetworkManager 2>&1 1>&3)

case $INTERNET in
        1)
        pacstrap /mnt dhcpcd
        arch-chroot /mnt systemctl enable dhcpcd
        ;;
        2)
        pacstrap /mnt networkmanager
        arch-chroot /mnt systemctl enable NetworkManager
        ;;
esac

THREADS=$(nproc)

sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$THREADS'"/g' /mnt/etc/makepkg.conf

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt systemctl enable fstrim.timer

sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=3/g' /mnt/etc/default/grub
sed -i 's/quiet/loglevel=3 quiet vga=current modprobe_blacklist=pcspkr,iTCO_wdt mitigations=off nowatchdog/g' /mnt/etc/default/grub
sed -i 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080x32/g' /mnt/etc/default/grub 

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

mkdir -p  /mnt/etc/systemd/system/getty@tty1.service.d/
echo -e "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin $USER --noclear %I $TERM" > /mnt/etc/systemd/system/getty@tty1.service.d/override.conf

arch-chroot /mnt systemctl enable getty@

arch-chroot /mnt passwd
arch-chroot /mnt passwd $USER

umount -R /mnt

reboot
