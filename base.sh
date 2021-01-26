#!/usr/bin/env bash

set -euxo pipefail

umount -R /mnt

pacman -S dialog --needed

DIALOG='dialog --cursor-off-label --colors --no-mouse'
DIALOGSIZE='0 0'

nohup timedatectl set-ntp true > /dev/null 2>&1 &

# Redirect INPUT to STDOUT
exec 3>&1

DRIVES=$(lsblk -rpo "name,type,size,mountpoint" | grep 'disk' | awk '$4==""{printf "%s (%s)\n",$1,$3}')

DRIVE=$($DIALOG --title 'Choose drive to partition' --menu "" $DIALOGSIZE 0 $DRIVES 2>&1 1>&3)

# Race condition?
parted -s $DRIVE -- mklabel gpt
sleep 0.5
parted -s -a optimal $DRIVE -- mkpart ESP fat32 1Mib 512Mib
sleep 0.5
parted -s -a optimal $DRIVE -- mkpart primary 512MiB 100%
sleep 0.5

mkfs.xfs -f -s size=4096 $DRIVE\2
sleep 0.5
mount "$DRIVE"2 /mnt
sleep 0.5
mkdir /mnt/boot
sleep 0.5
mount "$DRIVE"1 /mnt/boot
sleep 0.5

CPU=$($DIALOG --checklist "Check your cpu microcode:" $DIALOGSIZE 3 intel-ucode "" 1 amd-ucode "" 2 2>&1 1>&3)

reflector --verbose --latest 200 --sort score --save /etc/pacman.d/mirrorlist

clear
pacstrap /mnt base base-devel linux linux-firmware dhcpcd grub efibootmgr xfsprogs $CPU

sleep 1

USER=$($DIALOG --inputbox 'Enter your username:' $DIALOGSIZE 2>&1 1>&3)

arch-chroot /mnt useradd -m -G wheel,storage,power,video,audio,rfkill,input $USER

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /mnt/etc/sudeors

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

arch-chroot /mnt locale-gen

arch-chroot /mnt hwclock --systohc


if ($DIALOG --yesno "Enable multilib?" $DIALOGSIZE) then
sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//;n;s/^#//}' /mnt/etc/pacman.conf
fi

if ($DIALOG --yesno "Enable pacman eastereggs?" $DIALOGSIZE) then
sed -i 's/#Color/Color\nILoveCandy/g' /mnt/etc/pacman.conf
fi

THREADS=$(nproc)

sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$THREADS'"/g' /mnt/etc/makepkg.conf

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt systemctl enable dhcpcd

arch-chroot /mnt systemctl enable fstrim.timer

sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=3/g' /mnt/etc/default/grub                                                                                                                                                                         
                                                                                                                                                                                                                                         
# sed resolution
                     
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB                                                                                                                                             
                                                                                                                                                                                                                                         
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg                                                                                                                                                                                    
           
echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin username --noclear %I $TERM" > /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
           
umount -R /mnt                                                                                                                                                                                                                           
                                                                                                                                                                                                                                         
reboot       
