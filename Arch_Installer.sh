#!/bin/bash
# Author: Vthyarilops
# 27/08/2020

# Introduction Text, basic explanation
if (whiptail --title "Introduction" --yesno "This is an Arch Linux install script. Make sure your hard drive is formatted and mounted at /dev/mnt if you use UEFI make sure your EFI partition is mounted to /mnt/boot/efi" 20 78); then


# Setup NTP
if (whiptail --title "NTP" --yesno "Would you like me to enable NTP and sync the clock?" 20 78); then
	timedatectl set-ntp true
else
	:
fi

# Pacman Keys
if (whiptail --title "Pacman Keys" --yesno "Would you like me to refresh Pacman's Keys?" 20 78); then
	pacman -Sy archlinux-keyring && pacman-key --init && pacman-key --populate archlinux && pacman-key --refresh-keys
else
	:
fi


# pacstrap part
BS=$(whiptail --title "Install" --radiolist "Would you like to install Base-devel?" 20 78 15 \
"BASEDEV" "Base + Devel (default)" ON \
"BASE" "Base" OFF \
"NOPE" "Do not install base system" OFF \
3>&1 1>&2 2>&3)
if [ "$BS" = "BASEDEV" ] ; then
	pacstrap -i /mnt base base-devel linux linux-firmware
elif [ "$BS" = "BASE" ] ; then 
	pacstrap -i /mnt base linux linux-firmware
elif [ "$BS" = "NOPE" ] ; then 
	:
fi


# FSTAB Part
if (whiptail --title "FSTAB" --yesno "Would you like me to generate FSTAB from UUID? DO NOT RUN THIS MULTIPLE TIMES!!!" 20 78); then
	genfstab -U -p /mnt >> /mnt/etc/fstab
else
	:
fi


# Chroot time
if (whiptail --title "Chroot" --yesno "Would you like to Chroot into install?" 20 78); then
	arch-chroot /mnt ./Arch_Chroot.sh
else
	:
fi


#Finally Reboot from out of the Chroot
if (whiptail --title "Reboot?" --yesno "Would you like to reboot into your install?" 20 78); then
	reboot
else
	:
fi

# Close Script if No was chosen at the start
else
    echo "Goodbye, exit status was $?."
fi

exit
