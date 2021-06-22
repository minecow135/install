sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common samba nginx mysql-server nodejs git supervisor rdiff-backup screen build-essential rsync default-jre-headless npm curl openssh-server php7.4-fpm php7.4 php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml certbot cockpit

echo '' >> /etc/samba/smb.conf
echo '[root]' >> /etc/samba/smb.conf
echo '    comment = root' >> /etc/samba/smb.conf
echo '    path = /' >> /etc/samba/smb.conf
echo '    read only = no' >> /etc/samba/smb.conf
echo '    browsable = yes' >> /etc/samba/smb.conf

read -p "root samba password: " smbpasswd
sudo smbpasswd -a root
echo "$smbpasswd"
sudo service smbd restart

sudo ufw allow samba
sudo ufw allow 'nginx full'
sudo ufw allow openssh
sudo ufw allow 25565
sudo ufw allow 9090

sudo git clone https://github.com/NamelessMC/Nameless-Installer.git /var/www/mc
sudo systemctl reload nginx

sudo reboot now
