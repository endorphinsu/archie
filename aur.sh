#!/usr/bin/env bash

cd
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -sirc
cd
rm -rf paru-bin
