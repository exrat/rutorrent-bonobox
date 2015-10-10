#!/bin/bash

# contrôle version debian & function
VERSION=$(cat /etc/debian_version)

function FONCDEP ()
{
echo "#dépôt paquet propriétaire
deb http://ftp2.fr.debian.org/debian/ $1 main non-free
deb-src http://ftp2.fr.debian.org/debian/ $1 main non-free" >> /etc/apt/sources.list.d/non-free.list

echo "# dépôt nginx
deb http://nginx.org/packages/mainline/debian/ $1 nginx
deb-src http://nginx.org/packages/mainline/debian/ $1 nginx" >> /etc/apt/sources.list.d/nginx.list

# clés
wget http://www.dotdeb.org/dotdeb.gpg
apt-key add dotdeb.gpg

wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
}

function FONCDEPNGINX ()
{
apt-get install -y nginx=1.9.5-1~"$1"
echo "# dépôt nginx
deb http://nginx.org/packages/debian/ $1 nginx
deb-src http://nginx.org/packages/debian/ $1 nginx" > /etc/apt/sources.list.d/nginx.list
}

cd /tmp || exit

if [[ $VERSION =~ 7. ]]; then

DEBNUMBER="Debian_7.0.deb"
DEBNAME="wheezy"

echo "# dépôt dotdeb php 5.6
deb http://packages.dotdeb.org $DEBNAME-php56 all
deb-src http://packages.dotdeb.org $DEBNAME-php56 all" >> /etc/apt/sources.list.d/dotdeb-php56.list

elif [[ $VERSION =~ 8. ]]; then

DEBNUMBER="Debian_8.0.deb"
DEBNAME="jessie"

# ouverture root "coucou les poneys"
sed -i "s/PermitRootLogin no/PermitRootLogin yes/g;" /etc/ssh/sshd_config
systemctl restart sshd.service

echo "# dépôt dotdeb
deb http://packages.dotdeb.org $DEBNAME all
deb-src http://packages.dotdeb.org $DEBNAME all" >> /etc/apt/sources.list.d/dotdeb.list

echo "# dépôt multimedia
deb http://www.deb-multimedia.org $DEBNAME main non-free" >> /etc/apt/sources.list.d/multimedia.list

# clé ffmpeg
wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/"$MULTIMEDIA"
dpkg -i "$MULTIMEDIA"

else
	set "130" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}" ; echo ""
	exit 1
fi

# depots standard
FONCDEP "$DEBNAME"
