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
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

# Updating grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable cups.service
echo "  Cups enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"

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
                    Cleaning
-------------------------------------------------------------------------
"
# Remove no password sudo rights
# sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
# sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# # Add sudo rights
# sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
# sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# rm -r $HOME/archNemo
# rm -r /home/$USERNAME/archNemo

# Replace in the same state
# cd $pwd
cd
