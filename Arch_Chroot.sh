#!/bin/bash
# Author: Vthyarilops
# 27/08/2020

# Set Timezone
if (whiptail --title "Timezone" --yesno "Set Timezone to EST and setup Locales?" 8 78); then
	ln -sf /usr/share/zoneinfo/American/Toronto /etc/localtime
	sed -i 's/^#en_CA\.UTF/en_CA\.UTF/' /etc/locale.gen
	locale-gen
	hwclock --systohc --utc
else
	:
fi


# Set Hostname
if (whiptail --title "Hostname" --yesno "Set Hostname now? Lowercase letters only" 8 78); then
	SETHOST=$(whiptail --inputbox "Please enter your hostname, only lowercase letters" 8 39 arch --title "Enter Hostname" 3>&1 1>&2 2>&3)
	echo "$SETHOST" > /etc/hostname
else
	:
fi


# Set Root Password
while true; do
ROOTPASSWORD=$(whiptail --passwordbox "Please enter a Root password" 8 78 --title "Root Password" 3>&1 1>&2 2>&3)
ROOTPASSWORD2=$(whiptail --passwordbox "Please confirm your password" 8 78 --title "Confirm Password" 3>&1 1>&2 2>&3)
 [ "$ROOTPASSWORD" = "$ROOTPASSWORD2" ] && break
done
echo "root:$ROOTPASSWORD" | chpasswd


# Setup Users
if (whiptail --title "User" --yesno "Setup a Regular non Root user account?" 8 78); then
	SETUSER=$(whiptail --inputbox "Please enter a Username, only lowercase letters" 8 39 arch --title "Enter Username" 3>&1 1>&2 2>&3)
	useradd -m -G wheel -s /bin/bash "$SETUSER"
	while true; do
	USERPASSWORD=$(whiptail --passwordbox "Please enter a user password" 8 78 --title "User Password" 3>&1 1>&2 2>&3)
	USERPASSWORD2=$(whiptail --passwordbox "Please confirm your password" 8 78 --title "Confirm Password" 3>&1 1>&2 2>&3)
 	[ "$USERPASSWORD" = "$USERPASSWORD2" ] && break
	done
	echo "$SETUSER:$USERPASSWORD" | chpasswd
else
	;
fi


# Setup Bootloader
if (whiptail --title "Bootloader" --yesno "Would you like to install GRUB2?" 8 78); then
GRB=$(whiptail --inputbox "Enter the path to your hard drive, lowercase only. /dev/sda for example" 8 39 arch --title "Enter HDD" 3>&1 1>&2 2>&3)
BLS=$(whiptail --title "Bootloader Install" --radiolist "How do you want to install GRUB2?" 20 78 15 \
"BIOS" "GRUB + OS-Prober 32/64-bit BIOS/MBR (default)" ON \
"UEFI32" "GRUB + OS-Prober 32-bit UEFI/GPT" OFF \
"UEFI64" "GRUB + OS-Prober 64-bit UEFI/GPT" OFF \
3>&1 1>&2 2>&3)
if [ "$BLS" = "BIOS" ] ; then
	pacman -S grub os-prober
	grub-install --target=i386-pc --recheck $GRB
	grub-mkconfig -o /boot/grub/grub.cfg
elif [ "$BLS" = "UEFI32" ] ; then 
	pacman -S dosfstools efibootmgr grub os-prober
	grub-install --target=i386-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck
	grub-mkconfig -o /boot/grub/grub.cfg
elif [ "$BLS" = "UEFI64" ] ; then 
	pacman -S dosfstools efibootmgr grub os-prober
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck
	grub-mkconfig -o /boot/grub/grub.cfg
fi
else
	:
fi


exit

