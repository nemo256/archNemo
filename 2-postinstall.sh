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
# Optimize grub for macbook air and skip through it (I don't multiboot)
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& rootflags=data=writeback libata.force=1:noncq/' /etc/default/grub
sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
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
systemctl stop transmission.service
echo "  Transmission Daemon stopped"
killall -HUP transmission-da
echo "  Killing all transmission sub processes"
systemctl disable --now transmission.service
echo "  Transmission disabled"
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
                    Github configuration
-------------------------------------------------------------------------
"
# Git global configuration
git config --global user.username 'nemo256'
git config --global user.name 'Amine Neggazi'
git config --global user.email 'neggazimedlamine@gmail.com'
git config --global pull.rebase false

# Enable git store credentials
git config --global credential.helper store

# Adding the credentials file
echo -ne "https://nemo256:${TOKEN}@github.com" > $HOME/.git-credentials

echo -ne "
-------------------------------------------------------------------------
                    Installing dwm, st...
-------------------------------------------------------------------------
"
# Cloning my dotfiles
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
cd .. && git clone https://github.com/hhirsch/abook
cd abook && make && make install

# Alder
yarn global add @aweary/alder

# Grabc
cd .. && git clone https://github.com/muquit/grabc
cd grabc && make && make install

# Picom
# cd .. && git clone https://github.com/jonaburg/picom
# cd picom
# meson --buildtype=release . build
# ninja -C build
# sudo ninja -C build install

# Tremc
cd .. && git clone https://github.com/tremc/tremc
cd tremc && make install

# Weather-cli
yarn global add weather-cli

echo -ne "
-------------------------------------------------------------------------
                    Cloning backed up directories
-------------------------------------------------------------------------
"
cd $HOME && mkdir Downloads Videos Music Work
git clone https://github.com/nemo256/Documents
git clone https://github.com/nemo256/Pictures
cd Work
git clone https://github.com/nemo256/archNemo
git clone https://github.com/nemo256/collab
git clone https://github.com/nemo256/DashRecours
git clone https://github.com/nemo256/hotel
git clone https://github.com/nemo256/portfolio
git clone https://github.com/nemo256/Rproject
git clone https://github.com/nemo256/tc
cd $HOME

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

# Stowing configuration files
stow abook
stow alsa
stow bin
stow bash
stow dunst
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
stow nvim
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
                    Firefox configuration
-------------------------------------------------------------------------
"
# Saving path to prefs.js file
prefs=$(find $HOME/.mozilla/ -name '*prefs.js')

# Adding magnet link support
echo -ne '
user_pref("network.protocol-handler.expose.magnet", false);
' >> $prefs

echo -ne "
-------------------------------------------------------------------------
                    Fonts installation
-------------------------------------------------------------------------
"
# Adding nerd font (Droid Sans Mono)
# mkdir -p ~/.fonts
# cd ~/.fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

# Update fonts
# fc-cache -f -v

# Return back to home directory
# cd $HOME

echo -ne "
-------------------------------------------------------------------------
                    Slock configuration
-------------------------------------------------------------------------
"
# Adding slock service
echo -ne '[Unit]
Description=Lock X session using slock for user %i
Before=sleep.target

[Service]
User=%i
Environment=DISPLAY=:0
ExecStartPre=/usr/bin/xset dpms force suspend
ExecStart=/usr/local/bin/slock

[Install]
WantedBy=sleep.target
' > /etc/systemd/system/slock@.service

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
# Enabling slock to lock screen on suspend / sleep
systemctl enable slock@$(whoami).service
echo "  Slock enabled"

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"
rm -fvr $HOME/archNemo
