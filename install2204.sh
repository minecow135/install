sudo apt update
sudo apt upgrade -y
sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common samba nginx apache2 libapache2-mod-php mysql-server nodejs git supervisor rdiff-backup screen build-essential rsync default-jre-headless npm curl openssh-server php8.1-fpm php8.1 php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml certbot python3-certbot-nginx  python3-certbot-apache cockpit python3 python-is-python3 qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo docker run -d -p 8000:8000 -p 9000:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.11.1

sudo ufw allow samba
sudo ufw allow 'Apache Full'
sudo ufw allow openssh
sudo ufw allow 9090
yes | sudo ufw enable

sudo adduser $USER kvm
sudo adduser $USER libvirt
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

gsettings set org.gnome.shell.extensions.dash-to-dock click-action minimize
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

# Make sure that NOBODY can access the server without a password
#mysql -e "UPDATE mysql.user SET Password = PASSWORD('password') WHERE User = 'root'"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'password'"
# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql -e "DROP DATABASE test"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param

echo "
<VirtualHost *:8100>
    ServerName adm
#    ServerAlias www.your_domain 
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/adm
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/adm.conf

sudo mkdir /var/www/adm
#git pull https://github.com/phpmyadmin/phpmyadmin.git /var/www/adm
sudo a2ensite adm
	
echo "
<VirtualHost *:8101>
    ServerName web
#    ServerAlias www.your_domain 
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/web
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/web.conf

sudo mkdir /var/www/web
sudo a2ensite web
	
echo "
<VirtualHost *:8102>
    ServerName html
#    ServerAlias www.your_domain 
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/web
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/html.conf

echo "
<VirtualHost *:8103>
    ServerName skole
#    ServerAlias www.your_domain 
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/web
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/skole.conf

sudo mkdir /var/www/skole
sudo a2ensite skole
	
sudo systemctl stop  nginx.service
sudo systemctl stop nginx.service
sudo systemctl enable apache2
sudo systemctl start apache2
	
sudo chown -R $USER:www-data /var/www/

echo "
[root]
    comment = root
    path = /
    read only = no
    browsable = yes" | sudo tee -a /etc/samba/smb.conf
sudo smbpasswd -a root
echo "https://extensions.gnome.org/extension/3193/blur-my-shell/"
echo "https://extensions.gnome.org/extension/307/dash-to-dock-for-cosmic/"
