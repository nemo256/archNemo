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
                    Creating grub boot menu
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
                    Managing essential services
-------------------------------------------------------------------------
"
systemctl disable transmission.service
echo "  Transmission Daemon disabled"
systemctl stop transmission.service
echo "  Transmission Daemon stopped"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"

echo -ne "
-------------------------------------------------------------------------
                    Changing default console font
-------------------------------------------------------------------------
"
echo -ne 'KEYMAP="us"
FONT="ter-v32b"
' > /etc/vconsole.conf

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

# Abook
git clone https://github.com/hhirsch/abook
cd abook && make install

# Alder
yarn global add @aweary/alder

# Grabc
git clone https://github.com/muquit/grabc
cd grabc && make install

# Tremc
git clone https://github.com/tremc/tremc
cd tremc && make install

# Weather-cli
yarn global add weather-cli

echo -ne "
-------------------------------------------------------------------------
                    Cloning backed up directories
-------------------------------------------------------------------------
"

git clone https://github.com/nemo256/Documents
git clone https://github.com/nemo256/Pictures
mkdir Downloads Videos Music Work
cd Work
git clone https://github.com/nemo256/archNemo
git clone https://github.com/nemo256/collab
git clone https://github.com/nemo256/DashRecours
git clone https://github.com/nemo256/hotel
git clone https://github.com/nemo256/portfolio
git clone https://github.com/nemo256/Rproject
git clone https://github.com/nemo256/tc
cd

echo -ne "
-------------------------------------------------------------------------
                    Stowing configuration files
-------------------------------------------------------------------------
"
# Removing default files
rm -fvr $HOME/.bash*
rm -fvr $HOME/.gitconfig
rm -fvr $HOME/.config/*

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
stow ncmpcpp
stow neofetch
stow newsboat
stow notmuch
stow neovim
stow ranger
stow transmission-daemon
stow tremc
stow weather-cli-nodejs
stow xinit
stow yarn
stow zathura

echo -ne "
-------------------------------------------------------------------------
                    Neovim configuration
-------------------------------------------------------------------------
"
# Adding vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Installing neovim plugins
nvim -c 'PlugInstall | q! | q!'

echo -ne "
-------------------------------------------------------------------------
                    Ranger configuration
-------------------------------------------------------------------------
"
# Adding devicons to ranger
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons

echo -ne "
-------------------------------------------------------------------------
                    Fixing default configuration
-------------------------------------------------------------------------
"
# Touchpad configuration
echo -ne 'Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Option "Tapping" "True"
    Option "TappingDrag" "True"
    Option "ScrollMethod" "Twofinger"
    Option "NaturalScrolling" "False"
    Option "DisableWhileTyping" "False"
    Driver "libinput"
EndSection
' > /etc/X11/xorg.conf.d/40-libinput.conf

echo -ne "
-------------------------------------------------------------------------
                    Re-enabling essential services
-------------------------------------------------------------------------
"
systemctl enable --now transmission.service
echo "  Transmission Daemon enabled"
systemctl start transmission.service
echo "  Transmission Daemon started"

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"
rm -fvr $HOME/archNemo

cd
