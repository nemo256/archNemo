#!/usr/bin/env bash
# This script will set preferences 
# like disk, file system, timezone, keyboard layout,
# password, etc.

# Set up a config file
CONFIG_FILE=$SCRIPT_DIR/setup.conf
if [ ! -f $CONFIG_FILE ]; then # check if file exists
    touch -f $CONFIG_FILE # create file if not exists
fi

# Set options in setup.conf
set_option() {
    if grep -Eq "^${1}.*" $CONFIG_FILE; then # check if option exists
        sed -i -e "/^${1}.*/d" $CONFIG_FILE # delete option if exists
    fi
    echo "${1}=${2}" >>$CONFIG_FILE # add option
}

# My logo
logo () {
# This will be shown on every set as user is progressing
echo -ne "
--------------------------------------------------------------------------
  ░█████╗░██████╗░░█████╗░██╗░░██╗  ███╗░░██╗███████╗███╗░░░███╗░█████╗░
  ██╔══██╗██╔══██╗██╔══██╗██║░░██║  ████╗░██║██╔════╝████╗░████║██╔══██╗
  ███████║██████╔╝██║░░╚═╝███████║  ██╔██╗██║█████╗░░██╔████╔██║██║░░██║
  ██╔══██║██╔══██╗██║░░██╗██╔══██║  ██║╚████║██╔══╝░░██║╚██╔╝██║██║░░██║
  ██║░░██║██║░░██║╚█████╔╝██║░░██║  ██║░╚███║███████╗██║░╚═╝░██║╚█████╔╝
  ╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝  ╚═╝░░╚══╝╚══════╝╚═╝░░░░░╚═╝░╚════╝░
--------------------------------------------------------------------------

"
}

# Get user password (root only install)
userinfo () {
echo -ne "Please enter your password: "
read -s password

echo -ne "Please enter your Github PAT: "
read -s PAT

set_option USERNAME root
set_option TOKEN $PAT
set_option PASSWORD $password
}

# Setting up configuration options
clear
logo
userinfo
set_option NAME_OF_MACHINE macbook
set_option DESKTOP_ENV server
set_option INSTALL_TYPE MINIMAL
set_option AUR_HELPER yay
set_option DISK /dev/sda
set_option MOUNT_OPTIONS "noatime,compress=zstd,ssd,commit=120"
set_option FS ext4
set_option TIMEZONE Africa/Algiers
set_option KEYMAP us
