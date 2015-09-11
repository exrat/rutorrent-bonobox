#!/bin/bash

# contrôle version debian
VERSION=$(cat /etc/debian_version)

cd /tmp || exit

if [[ $VERSION =~ 7. ]]; then

# ajout des dépots debian 7
echo "#dépôt paquet propriétaire
deb http://ftp2.fr.debian.org/debian/ wheezy main non-free
deb-src http://ftp2.fr.debian.org/debian/ wheezy main non-free" >> /etc/apt/sources.list.d/non-free.list

echo "# dépôt dotdeb php 5.6
deb http://packages.dotdeb.org wheezy-php56 all
deb-src http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list.d/dotdeb-php56.list

echo "# dépôt nginx
deb http://nginx.org/packages/debian/ wheezy nginx
deb-src http://nginx.org/packages/debian/ wheezy nginx" >> /etc/apt/sources.list.d/nginx.list

# ajout des clés

# dotdeb
wget http://www.dotdeb.org/dotdeb.gpg
apt-key add dotdeb.gpg

# nginx
wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key

DEB="Debian_7.0.deb"

elif [[ $VERSION =~ 8. ]]; then

# ouverture root "coucou les poneys"
sed -i "s/PermitRootLogin no/PermitRootLogin yes/g;" /etc/ssh/sshd_config
systemctl restart sshd.service

# ajout des dépots debian 8
echo "#dépôt paquet propriétaire
deb http://ftp2.fr.debian.org/debian/ jessie main non-free
deb-src http://ftp2.fr.debian.org/debian/ jessie main non-free" >> /etc/apt/sources.list.d/non-free.list

echo "# dépôt dotdeb
deb http://packages.dotdeb.org jessie all
deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list

echo "# dépôt multimedia
deb http://www.deb-multimedia.org jessie main non-free" >> /etc/apt/sources.list.d/multimedia.list

# ajout des clés

# dotdeb
wget http://www.dotdeb.org/dotdeb.gpg
apt-key add dotdeb.gpg

# ffmpeg
wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/"$MULTIMEDIA"
dpkg -i "$MULTIMEDIA"

DEB="Debian_8.0.deb"

else
	set "130" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}" ; echo ""
	exit 1
fi
