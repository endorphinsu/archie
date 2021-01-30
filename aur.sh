#!/usr/bin/env bash

sudo pacman -S git --noconfirm --needed

cd
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -sirc
cd
rm -rf paru-bin
