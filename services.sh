#!/bin/bash
# What does it do: Automated server setup - services 
# Who wrote this: Marek Bubeník
# Date: 20220518
# 
####################################################################

# ---- both servers ----
apt update;
apt upgrade -y;
apt install vim -y;


# ---- polypi ----
if [ $HOSTNAME = "polypi" ]; then

	# ---- UFW firewall ----

	apt install ufw -y;
	systemctl start ufw;
	systemctl enable ufw;
	ufw default allow outgoing;
	ufw default deny incoming;
	ufw allow ssh;
	ufw allow http;
	ufw allow https;
	ufw allow Samba;
	ufw allow NFS;
	ufw logging on;
	ufw enable;

	# ---- Git setup ----
	
	apt install git -y;
	git config --global user.name "Marek Bubenik";
	git config --global user.email "b_mar@tuta.io";

	# ---- Docker setup ----

	# Setup docker repo
	# URL: https://docs.docker.com/engine/install/debian/https://docs.docker.com/engine/install/debian/
	
	sudo apt-get install ca-certificates curl gnupg lsb-release -y;
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg;
	echo \
  	"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  	$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;

	# Install Docker Engine

	apt-get update;
	apt-get install docker-ce docker-ce-cli containerd.io -y;

	# Post-installation steps

	groupadd docker;
	usermod -aG docker pi;

	# Configure Docker to start on boot

	systemctl enable docker.service;
	systemctl enable containerd.service;

	# ---- Samba setup ----
	
	apt install samba smbclient cifs-utils -y;
	systemctl enable --now smbd.service;
	systemctl enable --now nmbd.service;

	mv smb.conf /etc/samba/;

	systemctl restart smbd.service;
	systemctl restart nmbd.service;

	# Create and enable a user for samba share

	adduser -M sambapi -s /sbin/nologin;

	smbpasswd -a sambapi;
	smbpasswd -e sambapi;

	# Edit folder permissions/ownership
	
	chmod 2770 /mnt/vault/samba_share;
	chown -R root:sambapi /mnt/vault/samba_share; 

	# Test your configuration

	testparm;

	systemctl restart smbd.service;
	systemctl restart nmbd.service;

	# ---- NFS server setup ----

	apt install nfs-kernel-server -y;

	systemctl start nfs-server.service;
	systemctl enable nfs-server.service;
	
	echo "/mnt/vault/nfs_folder	192.168.1.81(rw,sync,no_root_squash)">>/etc/exports;
	exportfs -arv;
	exportfs -s;


# ---- monopi ----
elseif [ $HOSTNAME = "monopi" ]; then

	# ---- UFW firewall ----

	apt install ufw -y;
	systemctl start ufw;
	systemctl enable ufw;
	ufw default allow outgoing;
	ufw default deny incoming;
	ufw allow ssh;
	ufw logging on;
	ufw enable;	

	
	# ---- NFS client setup ----

	apt install nfs-common -y;
	mount -t nfs 192.168.1.80:/mnt/vault/nfs_folder /mnt;
	echo "192.168.1.80:/mnt/vault/nfs_folder	/mnt	nfs	defaults	0	0" >> /etc/fstab;

else
	echo "Seems like you did not setup aproparate hostnames for servers"
	echo "OR"
	echo "you are using this in your own environment... in that case..."
	echo "I am not responsible for damages this script would do to your environment!"
	echo "You are on your own, you have been warned! :3"
	exit 1
fi
