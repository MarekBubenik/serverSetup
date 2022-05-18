#!/bin/bash
# What does it do: Automated server setup - skeleton
# Who wrote this: Marek Bubeník
# Date: 20220518
# 
####################################################################

# ---- both servers ----
apt update;
apt upgrade -y;
# raspi-config					# optional
# sed **** ssh konfigurace

# ---- polypi ----
if [ $HOSTNAME = "polypi" ]; then

	# Initialize disk so we can put stuff in it
	parted /dev/sda mklabel gpt;		# TODO
	fdisk;					# TODO
	mkfs.ext4 /dev/sda1;
	mount /dev/sda1 /mnt/vault;
	mkdir /mnt/vault/containers /mnt/vault/samba_share /mnt/vault/nfs_folder;
	chown -R pi:pi /mnt/vault/containers;

# ---- monopi ----
elseif [ $HOSTNAME = "monopi" ]; then
	

else
	echo "Seems like you did not setup aproparate hostnames for servers"
	echo "OR"
	echo "you are using this in your own environment... in that case..."
	echo "I am not responsible for damages this script would do to your environment!"
	echo "You are on your own, you have been warned! :3"
	exit 1
fi
