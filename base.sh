#!/usr/bin/env bash

# Goal: No brainer KISS script

region=Europe
city=Vilnius
myusername=you
myhostname=archie
ucode=intel-ucode
drive=/dev/sda

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_ #

umount -R /mnt

for number in {1..9}   
do
parted $drive -- rm "$drive"$number
echo "$number"                              
done                                

parted -s $drive mklabel gpt

parted -s -a optimal $drive -- mkpart ESP fat32 1Mib 512Mib

parted -s -a optimal $drive -- mkpart primary 512MiB 100%

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_ #

mkfs.f2fs -f "$drive"2
mkfs.fat -F 32 "$drive"1

mount "$drive"2 /mnt
mkdir /mnt/boot
mount "$drive"1 /mnt/boot

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_ #

timedatectl set-ntp true

reflector --verbose --latest 200 --sort score --save /etc/pacman.d/mirrorlist
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware dhcpcd grub efibootmgr $ucode

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

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_ #

arch-chroot /mnt useradd -m -G wheel,storage,power,video,audio,rfkill,input $myusername

arch-chroot /mnt passwd
arch-chroot /mnt passwd $myusername

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /mnt/etc/sudeors

echo -e "\nDefaults insults" >> /mnt/etc/sudoers

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_ #

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

umount -R /mnt

reboot
