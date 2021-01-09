#!/usr/bin/env bash

# Goal: No brainer KISS script

region=Europe
city=Vilnius
myusername=Glorious
myhostname=Archie
ucode=intel-ucode
drive=/dev/sda

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_ #

umount -R /mnt

parted $drive mklabel gpt

parted -s -a optimal $drive -- mkpart ESP fat32 1Mib 512Mib

parted -s -a optimal $drive -- mkpart primary 512MiB 100%

timedatectl set-ntp true

mkfs.f2fs -f "$drive"2
mkfs.fat -F 32 "$drive"1

mount "$drive"2 /mnt
mkdir /mnt/boot
mount "$drived"1 /mnt/boot

reflector --verbose --latest 200 --sort score --save /etc/pacman.d/mirrorlist
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr $ucode

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt systemctl start dhcpcd

ln -sf /usr/share/zoneinfo/$region/$city /mnt/etc/localtime

arch-chroot /mnt hwclock --systohc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /mnt/etc/locale.gen

echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

arch-chroot /mnt locale-gen

echo "$myhostname" > /mnt/etc/hostname

echo "127.0.0.1	localhost
::1		localhost
127.0.1.1	$myhostname.localdomain	$myhostname
" >> /mnt/etc/hosts

sed -i 's/#Color/Color\nILoveCandy/g' /mnt/etc/pacman.conf

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /mnt/etc/sudeors

echo -e "\nDefaults Insults" >> /mnt/etc/sudoers

arch-chroot /mnt useradd -m -g users -G wheel,storage,power,video,audio,rfkill,input $myusername

arch-chroot /mnt passwd
arch-chroot /mnt passwd $User

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

umount -R /mnt

reboot
