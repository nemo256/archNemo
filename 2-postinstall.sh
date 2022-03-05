#!/usr/bin/env bash

echo -ne "
--------------------------------------------------------------------------
  ░█████╗░██████╗░░█████╗░██╗░░██╗  ███╗░░██╗███████╗███╗░░░███╗░█████╗░
  ██╔══██╗██╔══██╗██╔══██╗██║░░██║  ████╗░██║██╔════╝████╗░████║██╔══██╗
  ███████║██████╔╝██║░░╚═╝███████║  ██╔██╗██║█████╗░░██╔████╔██║██║░░██║
  ██╔══██║██╔══██╗██║░░██╗██╔══██║  ██║╚████║██╔══╝░░██║╚██╔╝██║██║░░██║
  ██║░░██║██║░░██║╚█████╔╝██║░░██║  ██║░╚███║███████╗██║░╚═╝░██║╚█████╔╝
  ╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝  ╚═╝░░╚══╝╚══════╝╚═╝░░░░░╚═╝░╚════╝░
--------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        SCRIPTHOME: archNemo
-------------------------------------------------------------------------

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source ${HOME}/archNemo/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
--------------------------------------------------------------------------
                    Creating Grub Boot Menu
--------------------------------------------------------------------------
"
# Set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& rootflags=data=writeback libata.force=1:noncq/' /etc/default/grub
sed -i 's/^#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y/' /etc/default/grub

# Updating grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"

echo -ne "
-------------------------------------------------------------------------
                    Installing dwm, st...
-------------------------------------------------------------------------
"
# Cloning dotfiles
cd $HOME
git clone https://github.com/nemo256/.dotfiles

# Adding a build folder
mkdir .build && cd .build

# Cloning my repos
git clone https://github.com/nemo256/dwm
git clone https://github.com/nemo256/st
git clone https://github.com/nemo256/dmenu
git clone https://github.com/nemo256/slock
git clone https://github.com/nemo256/slstatus

# Building using the make command
cd dwm && make clean install
cd ../st && make clean install
cd ../dmenu && make clean install
cd ../slock && make clean install
cd ../slstatus && make clean install

# Grabc
git clone https://github.com/muquit/grabc
cd grabc && make install

# Abook
git clone https://github.com/hhirsch/abook
cd abook && make install

# Alder
yarn global add @aweary/alder

echo -ne "
-------------------------------------------------------------------------
                    Stowing configuration files
-------------------------------------------------------------------------
"
# Removing default files
rm -fvr $HOME/.bash*
rm -fvr $HOME/.gitconfig

# Dotfiles directory
cd $HOME/.dotfiles

# Stowing
stow abook
stow alsa
stow bin
stow bash
stow dunst
stow git
stow gtk-2.0
stow gtk-3.0
stow htop
stow irssi
stow mbsync
stow mimeapps
stow mpd
stow mpv
stow mutt

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"

rm -r $HOME/archNemo
rm -r /home/

cd
