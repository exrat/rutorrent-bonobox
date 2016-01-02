#!/bin/bash
#
# Script d'installation ruTorrent / Nginx
# Auteur : Ex_Rat
#
# Nécessite Debian 7 ou 8 (32/64 bits) & un serveur fraîchement installé
#
# Multi-utilisateurs
# Inclus VsFTPd (ftp & ftps sur le port 21), Fail2ban (avec conf nginx, ftp & ssh) & Proxy php
# Seedbox-Manager, Auteurs: Magicalex, Hydrog3n et Backtoback
#
# Tiré du tutoriel de Magicalex pour mondedie.fr disponible ici:
# http://mondedie.fr/viewtopic.php?id=5302
# Aide, support & plus si affinités à la même adresse ! http://mondedie.fr/
#
# Merci Aliochka & Meister pour les conf de Munin et VsFTPd
# à Albaret pour le coup de main sur la gestion d'users,
# Jedediah pour avoir joué avec le html/css du thème.
# Aux traducteurs: Sophie, Spectre, Hardware, Zarev.
#
# Installation:
#
# apt-get update && apt-get upgrade -y
# apt-get install git-core -y
#
# cd /tmp
# git clone https://github.com/exrat/rutorrent-bonobox
# cd rutorrent-bonobox
# chmod a+x bonobox.sh && ./bonobox.sh
#
# Pour gérer vos utilisateurs ultérieurement, il vous suffit de relancer le script
#
# This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License


#  includes
INCLUDES="includes"
# shellcheck source=/dev/null
. "$INCLUDES"/variables.sh
# shellcheck source=/dev/null
. "$INCLUDES"/langues.sh
# shellcheck source=/dev/null
. "$INCLUDES"/functions.sh

# contrôle droits utilisateur
FONCROOT
clear

# Contrôle installation
if [ ! -f "$NGINXENABLE"/rutorrent.conf ]; then

# log de l'installation
exec > >(tee "/tmp/install.log")  2>&1

####################################
# lancement installation ruTorrent #
####################################

# message d'accueil
echo "" ; set "102" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""
# shellcheck source=/dev/null
. "$INCLUDES"/logo.sh

echo "" ; set "104" ; FONCTXT "$1" ; echo -e "${CYELLOW}$TXT1${CEND}"
set "106" ; FONCTXT "$1" ; echo -e "${CYELLOW}$TXT1${CEND}" ; echo ""

# demande nom et mot de passe
while :; do
set "108" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
FONCUSER
done

echo ""
while :; do
set "112" "114" "116" ; FONCTXT "$1" "$2" "$3" ; echo -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$TXT2${CEND} ${CGREEN}$TXT3 ${CEND}"
FONCPASS
done

PORT=5001

# email admin seedbox-Manager
while :; do
echo "" ; set "124" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
read -r INSTALLMAIL
if [ "$INSTALLMAIL" = "" ]; then
	EMAIL=contact@exemple.com
	break

else
	if [[ "$INSTALLMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]*$ ]]; then
	EMAIL="$INSTALLMAIL"
	break
	else
		echo "" ; set "126" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
	fi
fi
done

# installation vsftpd
echo "" ; set "128" ; FONCTXT "$1" ; echo -n -e "${CGREEN}$TXT1 ${CEND}"
read -r SERVFTP

# récupération 5% root sur /home ou /home/user si présent
FSHOME=$(df -h | grep /home | cut -c 6-9)
if [ "$FSHOME" = "" ]; then
	echo
else
	tune2fs -m 0 /dev/"$FSHOME" &> /dev/null
	mount -o remount /home &> /dev/null
fi

FONCFSUSER "$USER"

# variable passe nginx
PASSNGINX=${USERPWD}

# ajout utilisateur
useradd -M -s /bin/bash "$USER"

# création du mot de passe utilisateur
echo "${USER}:${USERPWD}" | chpasswd

# anti-bug /home/user déjà existant
mkdir -p /home/"$USER"
chown -R "$USER":"$USER" /home/"$USER"

# variable utilisateur majuscule
USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

# récupération IP serveur
IP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ "$IP" = "" ]; then
	IP=$(wget -qO- ipv4.icanhazip.com)
fi

# récupération threads & sécu -j illimité
THREAD=$(grep -c processor < /proc/cpuinfo)
if [ "$THREAD" = "" ]; then
    THREAD=1
fi

# ajout depots
# shellcheck source=/dev/null
. "$INCLUDES"/deb.sh

# bind9 & dhcp
if [ ! -d /etc/bind ]; then
	rm /etc/init.d/bind9
	apt-get install -y bind9
fi

if [ -f /etc/dhcp/dhclient.conf ]; then
	sed -i "s/#prepend domain-name-servers 127.0.0.1;/prepend domain-name-servers 127.0.0.1;/g;" /etc/dhcp/dhclient.conf
fi

cp -f "$FILES"/bind/named.conf.options /etc/bind/named.conf.options

sed -i '/127.0.0.1/d' /etc/resolv.conf # pour éviter doublon
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
service bind9 restart

# installation des paquets
apt-get update && apt-get upgrade -y
echo "" ; set "132" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

apt-get install -y htop openssl apt-utils python build-essential  libssl-dev pkg-config automake libcppunit-dev libtool whois libcurl4-openssl-dev libsigc++-2.0-dev libncurses5-dev vim nano ccze screen subversion apache2-utils curl php5 php5-cli php5-fpm php5-curl php5-geoip unrar rar zip buildtorrent fail2ban ntp ntpdate munin ffmpeg aptitude dnsutils

# installation nginx et passage sur depot stable
FONCDEPNGINX "$DEBNAME"

echo "" ; set "136" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# génération clé 2048 bits
openssl dhparam -out dhparams.pem 2048 >/dev/null 2>&1 &

# téléchargement complément favicon
wget -T 10 -t 3 http://www.bonobox.net/script/favicon.tar.gz || wget -T 10 -t 3 http://alt.bonobox.net/favicon.tar.gz
tar xzfv favicon.tar.gz

# création fichiers couleurs nano
cp  "$FILES"/nano/ini.nanorc /usr/share/nano/ini.nanorc
cp  "$FILES"/nano/conf.nanorc /usr/share/nano/conf.nanorc
cp  "$FILES"/nano/xorg.nanorc /usr/share/nano/xorg.nanorc

# édition conf nano
echo "
## Config Files (.ini)
include \"/usr/share/nano/ini.nanorc\"

## Config Files (.conf)
include \"/usr/share/nano/conf.nanorc\"

## Xorg.conf
include \"/usr/share/nano/xorg.nanorc\"">> /etc/nanorc
echo "" ; set "138" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# Config ntp & réglage heure fr
if [ "$BASELANG" = "fr" ]; then
echo "Europe/Paris" > /etc/timezone
cp /usr/share/zoneinfo/Europe/Paris /etc/localtime

sed -i "s/server 0/#server 0/g;" /etc/ntp.conf
sed -i "s/server 1/#server 1/g;" /etc/ntp.conf
sed -i "s/server 2/#server 2/g;" /etc/ntp.conf
sed -i "s/server 3/#server 3/g;" /etc/ntp.conf

echo "
server 0.fr.pool.ntp.org
server 1.fr.pool.ntp.org
server 2.fr.pool.ntp.org
server 3.fr.pool.ntp.org">> /etc/ntp.conf

ntpdate -d 0.fr.pool.ntp.org
fi

# installation XMLRPC LibTorrent rTorrent
cd /tmp || exit
#svn checkout http://svn.code.sf.net/p/xmlrpc-c/code/advanced xmlrpc-c
#if [ ! -d /tmp/xmlrpc-c ]; then
#	wget http://bonobox.net/script/xmlrpc-c.tar.gz
#	tar xzfv xmlrpc-c.tar.gz
#fi

wget http://bonobox.net/script/xmlrpc-c.tar.gz
tar xzfv xmlrpc-c.tar.gz

cd xmlrpc-c || exit
./configure #--disable-cplusplus
make -j "$THREAD"
make install
echo "" ; set "140" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# clone rTorrent et libTorrent
cd .. || exit
git clone https://github.com/rakshasa/libtorrent.git
git clone https://github.com/rakshasa/rtorrent.git

# libTorrent compilation
if [ ! -d /tmp/libtorrent ]; then
	wget http://rtorrent.net/downloads/libtorrent-"$LIBTORRENT".tar.gz
	tar xzfv libtorrent-"$LIBTORRENT".tar.gz
	mv libtorrent-"$LIBTORRENT" libtorrent
	cd libtorrent || exit
else
	cd libtorrent || exit
	git checkout "$LIBTORRENT"
fi

./autogen.sh
./configure
make -j "$THREAD"
make install
echo "" ; set "142" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1 $LIBTORRENT${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# rTorrent compilation
if [ ! -d /tmp/rtorrent ]; then
	cd /tmp || exit
	wget http://rtorrent.net/downloads/rtorrent-"$RTORRENT".tar.gz
	tar xzfv rtorrent-"$RTORRENT".tar.gz
	mv rtorrent-"$RTORRENT" rtorrent
	cd rtorrent || exit
else
cd ../rtorrent || exit
git checkout "$RTORRENT"
fi

./autogen.sh
./configure --with-xmlrpc-c
make -j "$THREAD"
make install
ldconfig
echo "" ; set "144" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1 $RTORRENT${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# création des dossiers
su "$USER" -c 'mkdir -p ~/watch ~/torrents ~/.session '

# création dossier scripts perso
mkdir "$SCRIPT"

# création accueil serveur
mkdir -p /var/www
cp -R "$BONOBOX"/base /var/www/base

# déplacement proxy
cp -R "$BONOBOX"/proxy /var/www/proxy

# téléchargement et déplacement de rutorrent
git clone https://github.com/Novik/ruTorrent.git "$RUTORRENT"
echo "" ; set "146" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# installation des Plugins
cd "$RUTORRENT"/plugins || exit

# logoff
cp -R "$BONOBOX"/plugins/logoff "$RUTORRENT"/plugins/logoff
#svn co http://rutorrent-logoff.googlecode.com/svn/trunk/ logoff

# chat
cp -R "$BONOBOX"/plugins/chat "$RUTORRENT"/plugins/chat
#svn co http://rutorrent-chat.googlecode.com/svn/trunk/ chat

# tadd-labels
cp -R "$BONOBOX"/plugins/lbll-suite "$RUTORRENT"/plugins/lbll-suite
#wget http://rutorrent-tadd-labels.googlecode.com/files/lbll-suite_0.8.1.tar.gz
#tar zxfv lbll-suite_0.8.1.tar.gz
#rm lbll-suite_0.8.1.tar.gz

# ruTorrentMobile
git clone https://github.com/xombiemp/rutorrentMobile.git mobile

# rutorrent-seeding-view
# git clone https://github.com/rMX666/rutorrent-seeding-view.git rutorrent-seeding-view

# linkproxy
cp -R "$BONOBOX"/plugins/linkproxy "$RUTORRENT"/plugins/

# linklogs
cp -R "$BONOBOX"/plugins/linklogs "$RUTORRENT"/plugins/

# nfo
cp -R "$BONOBOX"/plugins/nfo "$RUTORRENT"/plugins/nfo

# filemanager
cp -R "$BONOBOX"/plugins/filemanager "$RUTORRENT"/plugins/filemanager
#svn co http://svn.rutorrent.org/svn/filemanager/trunk/filemanager

# filemanager config
cp -f "$FILES"/rutorrent/filemanager.conf "$RUTORRENT"/plugins/filemanager/conf.php

# configuration du plugin create
sed -i "s#$(useExternal) = false;#$(useExternal) = 'buildtorrent';#" "$RUTORRENT"/plugins/create/conf.php
sed -i "s#$(pathToCreatetorrent) = '';#$(pathToCreatetorrent) = '/usr/bin/buildtorrent';#" "$RUTORRENT"/plugins/create/conf.php

# fileshare
cd "$RUTORRENT"/plugins || exit
cp -R "$BONOBOX"/plugins/fileshare "$RUTORRENT"/plugins/fileshare
#svn co http://svn.rutorrent.org/svn/filemanager/trunk/fileshare
chown -R www-data:www-data "$RUTORRENT"/plugins/fileshare
ln -s "$RUTORRENT"/plugins/fileshare/share.php /var/www/base/share.php

# configuration share.php
cp -f "$FILES"/rutorrent/fileshare.conf "$RUTORRENT"/plugins/fileshare/conf.php
sed -i "s/@IP@/$IP/g;" "$RUTORRENT"/plugins/fileshare/conf.php

# mediainfo
cd "$BONOBOX" || exit
. "$INCLUDES"/mediainfo.sh

# script mise à jour mensuel geoip et complément plugin city
# création dossier par sécurité suite bug d'install
mkdir /usr/share/GeoIP

# variable minutes aléatoire crontab geoip
MAXIMUM=58
MINIMUM=1
UPGEOIP=$((MINIMUM+RANDOM*(1+MAXIMUM-MINIMUM)/32767))

cd "$SCRIPT" || exit
cp "$FILES"/scripts/updateGeoIP.sh "$SCRIPT"/updateGeoIP.sh
chmod a+x updateGeoIP.sh
sh updateGeoIP.sh

# favicons trackers
cp /tmp/favicon/*.png "$RUTORRENT"/plugins/tracklabels/trackers/

# ratiocolor
cp -R "$BONOBOX"/plugins/ratiocolor "$RUTORRENT"/plugins/ratiocolor

# pausewebui
cp -R "$BONOBOX"/plugins/pausewebui "$RUTORRENT"/plugins/pausewebui
#cd "$RUTORRENT"/plugins
#svn co http://rutorrent-pausewebui.googlecode.com/svn/trunk/ pausewebui

# plugin seedbox-manager
cd "$RUTORRENT"/plugins || exit
git clone https://github.com/Hydrog3n/linkseedboxmanager.git
sed -i "2i\$host = \$_SERVER['HTTP_HOST'];\n" "$RUTORRENT"/plugins/linkseedboxmanager/conf.php
sed -i "s/http:\/\/seedbox-manager.ndd.tld/\/\/'. \$host .'\/seedbox-manager\//g;" "$RUTORRENT"/plugins/linkseedboxmanager/conf.php

# configuration logoff
sed -i "s/scars,user1,user2/$USER/g;" "$RUTORRENT"/plugins/logoff/conf.php

# ajout thèmes
rm -r "$RUTORRENT"/plugins/theme/themes/Blue
cp -R "$BONOBOX"/theme/ru/Blue "$RUTORRENT"/plugins/theme/themes/Blue
cp -R "$BONOBOX"/theme/ru/SpiritOfBonobo "$RUTORRENT"/plugins/theme/themes/SpiritOfBonobo

# configuration thème
sed -i "s/defaultTheme = \"\"/defaultTheme = \"SpiritOfBonobo\"/g;" "$RUTORRENT"/plugins/theme/conf.php

echo "" ; set "148" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# liens symboliques et permissions
ldconfig
chown -R www-data:www-data "$RUTORRENT"
chmod -R 777 "$RUTORRENT"/plugins/filemanager/scripts
chown -R www-data:www-data /var/www/base
chown -R www-data:www-data /var/www/proxy

# php
sed -i "s/2M/10M/g;" /etc/php5/fpm/php.ini
sed -i "s/8M/10M/g;" /etc/php5/fpm/php.ini
sed -i "s/expose_php = On/expose_php = Off/g;" /etc/php5/fpm/php.ini

if [ "$BASELANG" = "fr" ]; then
	sed -i "s/^;date.timezone =/date.timezone = Europe\/Paris/g;" /etc/php5/fpm/php.ini
	sed -i "s/^;date.timezone =/date.timezone = Europe\/Paris/g;" /etc/php5/cli/php.ini
else
	sed -i "s/^;date.timezone =/date.timezone = UTC/g;" /etc/php5/fpm/php.ini
	sed -i "s/^;date.timezone =/date.timezone = UTC/g;" /etc/php5/cli/php.ini
fi

sed -i "s/^;listen.owner = www-data/listen.owner = www-data/g;" /etc/php5/fpm/pool.d/www.conf
sed -i "s/^;listen.group = www-data/listen.group = www-data/g;" /etc/php5/fpm/pool.d/www.conf
sed -i "s/^;listen.mode = 0660/listen.mode = 0660/g;" /etc/php5/fpm/pool.d/www.conf

service php5-fpm restart
echo "" ; set "150" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

mkdir -p "$NGINXPASS" "$NGINXSSL"
touch "$NGINXPASS"/rutorrent_passwd
chmod 640 "$NGINXPASS"/rutorrent_passwd

# configuration serveur web
mkdir "$NGINXENABLE"
cp -f "$FILES"/nginx/nginx.conf "$NGINX"/nginx.conf
cp "$FILES"/nginx/php.conf "$NGINX"/conf.d/php.conf
cp "$FILES"/nginx/cache.conf "$NGINX"/conf.d/cache.conf
cp "$FILES"/nginx/ciphers.conf "$NGINX"/conf.d/ciphers.conf
cp "$FILES"/rutorrent/rutorrent.conf "$NGINXENABLE"/rutorrent.conf

echo "" ; set "152" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# installation munin
sed -i "s/#dbdir[[:blank:]]\/var\/lib\/munin/dbdir \/var\/lib\/munin/g;" /etc/munin/munin.conf
sed -i "s/#htmldir[[:blank:]]\/var\/cache\/munin\/www/htmldir \/var\/www\/monitoring/g;" /etc/munin/munin.conf
sed -i "s/#logdir[[:blank:]]\/var\/log\/munin/logdir \/var\/log\/munin/g;" /etc/munin/munin.conf
sed -i "s/#rundir[[:blank:]][[:blank:]]\/var\/run\/munin/rundir \/var\/run\/munin/g;" /etc/munin/munin.conf
sed -i "s/#max_size_x[[:blank:]]4000/max_size_x 5000/g;" /etc/munin/munin.conf
sed -i "s/#max_size_y[[:blank:]]4000/max_size_x 5000/g;" /etc/munin/munin.conf

mkdir -p "$MUNINROUTE"
chown -R munin:munin /var/www/monitoring

cd "$MUNIN" || exit

wget https://raw.github.com/munin-monitoring/contrib/master/plugins/rtorrent/rtom_mem
wget https://raw.github.com/munin-monitoring/contrib/master/plugins/rtorrent/rtom_peers
wget https://raw.github.com/munin-monitoring/contrib/master/plugins/rtorrent/rtom_spdd
wget https://raw.github.com/munin-monitoring/contrib/master/plugins/rtorrent/rtom_vol

FONCMUNIN "$USER" "$PORT"

cp -R "$BONOBOX"/graph "$GRAPH"

echo "" ; set "154" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# ssl configuration #

#!/bin/bash

openssl req -new -x509 -days 3658 -nodes -newkey rsa:2048 -out "$NGINXSSL"/server.crt -keyout "$NGINXSSL"/server.key<<EOF
RU
Russia
Moskva
wtf
wtf LTD
wtf.org
contact@wtf.org
EOF

rm -R /var/www/html
rm "$NGINXENABLE"/default

# installation Seedbox-Manager

## composer
cd /tmp || exit
curl -s http://getcomposer.org/installer | php
mv /tmp/composer.phar /usr/bin/composer
chmod +x /usr/bin/composer
echo "" ; set "156" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

## nodejs
cd /tmp || exit
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
# shellcheck source=/dev/null
source ~/.bashrc
nvm install v5.3.0
echo "" ; set "158" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

## bower
npm install -g bower
echo "" ; set "160" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

## app
cd /var/www || exit
composer create-project magicalex/seedbox-manager
cd seedbox-manager || exit
bower install --allow-root --config.interactive=false
chown -R www-data:www-data "$SBM"
## conf app
cd source-reboot-rtorrent || exit
chmod +x install.sh
./install.sh

cp "$FILES"/nginx/php-manager.conf "$NGINX"/conf.d/php-manager.conf

## conf user
cd "$SBM"/conf/users || exit
mkdir "$USER"
cp -f "$FILES"/sbm/config-root.ini "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/https:\/\/graph.domaine.fr/..\/graph\/$USER.php/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/\"\/\"/\"\/home\/$USER\"/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/RPC1/$USERMAJ/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/contact@mail.com/$EMAIL/g;" "$SBM"/conf/users/"$USER"/config.ini

# verrouillage option parametre seedbox-manager
cp -f "$FILES"/sbm/header.html "$SBM"/public/themes/default/template/header.html

chown -R www-data:www-data "$SBM"/conf/users
chown -R www-data:www-data "$SBM"/public/themes/default/template/header.html
echo "" ; set "162" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# logrotate
cp -f "$FILES"/nginx/logrotate /etc/logrotate.d/nginx

# script logs html ccze
mkdir "$RUTORRENT"/logserver
cd "$SCRIPT" || exit
cp "$FILES"/scripts/logserver.sh "$SCRIPT"/logserver.sh
sed -i "s/@USERMAJ@/$USERMAJ/g;" "$SCRIPT"/logserver.sh
sed -i "s|@RUTORRENT@|$RUTORRENT|;" "$SCRIPT"/logserver.sh
chmod +x logserver.sh
echo "" ; set "164" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# ssh config
sed -i "s/Subsystem[[:blank:]]sftp[[:blank:]]\/usr\/lib\/openssh\/sftp-server/Subsystem sftp internal-sftp/g;" /etc/ssh/sshd_config
sed -i "s/UsePAM/#UsePAM/g;" /etc/ssh/sshd_config

# chroot user
echo "Match User $USER
ChrootDirectory /home/$USER">> /etc/ssh/sshd_config

# permissions
chown -R "$USER":"$USER" /home/"$USER"
chown root:"$USER" /home/"$USER"
chmod 755 /home/"$USER"

service ssh restart
echo "" ; set "166" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# config .rtorrent.rc
 FONCTORRENTRC "$USER" "$PORT" "$RUTORRENT"

# config user rutorrent.conf
FONCRTCONF "$USERMAJ"  "$PORT" "$USER"

# config.php
mkdir "$RUTORRENT"/conf/users/"$USER"
FONCPHPCONF "$USER" "$PORT" "$USERMAJ"

# plugin.ini
cp "$FILES"/rutorrent/plugins.ini "$RUTORRENT"/conf/users/"$USER"/plugins.ini

# script rtorrent
FONCSCRIPTRT "$USER" 
service "$USER"-rtorrent start

# write out current crontab
crontab -l > rtorrentdem

# echo new cron into cron file
echo "$UPGEOIP 2 9 * * sh $SCRIPT/updateGeoIP.sh > /dev/null 2>&1
0 */2 * * * sh $SCRIPT/logserver.sh > /dev/null 2>&1" >> rtorrentdem

# install new cron file
crontab rtorrentdem
rm rtorrentdem

# htpasswd
 FONCHTPASSWD "$USER"

echo "" ; set "168" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# conf fail2ban
cp "$FILES"/fail2ban/nginx-auth.conf /etc/fail2ban/filter.d/nginx-auth.conf
cp "$FILES"/fail2ban/nginx-badbots.conf /etc/fail2ban/filter.d/nginx-badbots.conf

cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed  -i "/ssh/,+6d" /etc/fail2ban/jail.local

echo "
[ssh]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
banaction = iptables-multiport
maxretry = 5

[nginx-auth]
enabled  = true
port  = http,https
filter   = nginx-auth
logpath  = /var/log/nginx/*error.log
banaction = iptables-multiport
maxretry = 10

[nginx-badbots]
enabled  = true
port  = http,https
filter = nginx-badbots
logpath = /var/log/nginx/*access.log
banaction = iptables-multiport
maxretry = 5" >> /etc/fail2ban/jail.local

/etc/init.d/fail2ban restart
echo "" ; set "170" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""

# installation vsftpd
if FONCYES "$SERVFTP"; then
apt-get install -y vsftpd
cp -f "$FILES"/vsftpd/vsftpd.conf /etc/vsftpd.conf

if [[ $VERSION =~ 7. ]]; then
	sed -i "s/seccomp_sandbox=NO/#seccomp_sandbox=NO/g;" /etc/vsftpd.conf
fi

# récupèration certificats nginx
cp -f "$NGINXSSL"/server.crt  /etc/ssl/private/vsftpd.cert.pem
cp -f "$NGINXSSL"/server.key  /etc/ssl/private/vsftpd.key.pem

touch /etc/vsftpd.chroot_list
touch /var/log/vsftpd.log
chmod 600 /var/log/vsftpd.log
/etc/init.d/vsftpd reload

sed  -i "/vsftpd/,+10d" /etc/fail2ban/jail.local

echo "
[vsftpd]

enabled  = true
port     = ftp,ftp-data,ftps,ftps-data
filter   = vsftpd
logpath  = /var/log/vsftpd.log
banaction = iptables-multiport
# or overwrite it in jails.local to be
# logpath = /var/log/auth.log
# if you want to rely on PAM failed login attempts
# vsftpd's failregex should match both of those formats
maxretry = 5" >> /etc/fail2ban/jail.local

/etc/init.d/fail2ban restart
echo "" ; set "172" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""
fi

# déplacement clé 2048
cp /tmp/dhparams.pem "$NGINXSSL"/dhparams.pem
chmod 600 "$NGINXSSL"/dhparams.pem
service nginx restart
# Contrôle
if [ ! -f "$NGINXSSL"/dhparams.pem ]; then
kill -HUP "$(pgrep -x openssl)"
echo "" ; set "174" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
set "176" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}" ; echo ""
cd "$NGINXSSL" || exit
openssl dhparam -out dhparams.pem 2048
chmod 600 dhparams.pem
service nginx restart
echo "" ; set "178" "134" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND}${CGREEN}$TXT2${CEND}" ; echo ""
fi

# configuration page index munin
FONCGRAPH "$USER"

# log users
echo "maillog">> "$RUTORRENT"/histo.log
echo "userlog">> "$RUTORRENT"/histo.log
sed -i "s/maillog/$EMAIL/g;" "$RUTORRENT"/histo.log
sed -i "s/userlog/$USER:5001/g;" "$RUTORRENT"/histo.log

set "180" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"

echo "" ; set "182" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}"
set "184" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
set "186" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
set "188" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}" ; echo ""

# ajout utilisateur supplémentaire

while :; do
set "190" ; FONCTXT "$1" ; echo -n -e "${CGREEN}$TXT1 ${CEND}"
read -r REPONSE

if FONCNO "$REPONSE"; then

	# fin d'installation
	echo "" ; set "192" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
	cp /tmp/install.log "$RUTORRENT"/install.log
	sh "$SCRIPT"/logserver.sh
	ccze -h < "$RUTORRENT"/install.log > "$RUTORRENT"/install.html
	> /var/log/nginx/rutorrent-error.log
	echo "" ; set "194" ; FONCTXT "$1" ; echo -n -e "${CGREEN}$TXT1 ${CEND}"
	read -r REBOOT

	if FONCNO "$REBOOT"; then
		echo "" ; set "196" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		echo -e "${CYELLOW}https://$IP/rutorrent/install.html${CEND}"
		echo "" ; set "200" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
		echo ""
		set "202" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		echo -e "${CYELLOW}https://$IP/rutorrent/${CEND}"
		echo "" ; set "206" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		echo -e "${CYELLOW}https://$IP/seedbox-manager/${CEND}" ; echo ""
		echo "" ; set "210" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}" ; echo ""
		break
	fi

	if FONCYES "$REBOOT" = "y"; then
		echo "" ; set "196" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		echo -e "${CYELLOW}https://$IP/rutorrent/install.html${CEND}"
		echo "" ; set "202" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		echo -e "${CYELLOW}https://$IP/rutorrent/${CEND}"
		echo "" ; set "206" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		echo -e "${CYELLOW}https://$IP/seedbox-manager/${CEND}" ; echo ""
		echo "" ; set "210" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}" ; echo ""
		reboot
		break
	fi
fi

if FONCYES "$REPONSE" = "y"; then

# demande nom et mot de passe
echo ""
while :; do
set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
FONCUSER
done

echo ""
while :; do
set "112" "114" "116" ; FONCTXT "$1" "$2" "$3" ; echo -e "${CGREEN}$TXT1${CEND}${CYELLOW}$TXT2${CEND}${CGREEN}$TXT3 ${CEND}"
FONCPASS
done

# récupération 5% root sur /home/user si présent
FONCFSUSER "$USER"

# variable passe nginx
PASSNGINX=${USERPWD}

# ajout utilisateur
useradd -M -s /bin/bash "$USER"

# création du mot de passe pour cet utilisateur
echo "${USER}:${USERPWD}" | chpasswd

# anti-bug /home/user déjà existant
mkdir -p /home/"$USER"
chown -R "$USER":"$USER" /home/"$USER"

# variable utilisateur majuscule
USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

# variable mail
EMAIL=$(sed -n "1 p" "$RUTORRENT"/histo.log)

# création de dossier
su "$USER" -c 'mkdir -p ~/watch ~/torrents ~/.session '

# calcul port
HISTO=$(wc -l < "$RUTORRENT"/histo.log)
PORT=$(( 5001+HISTO ))

# configuration munin
FONCMUNIN "$USER" "$PORT"

# config .rtorrent.rc
 FONCTORRENTRC "$USER" "$PORT" "$RUTORRENT"

# config user rutorrent.conf
sed -i '$d' "$NGINXENABLE"/rutorrent.conf
FONCRTCONF "$USERMAJ"  "$PORT" "$USER"

# logserver user config
sed -i '$d' "$SCRIPT"/logserver.sh
echo "sed -i '/@USERMAJ@\ HTTP/d' access.log" >> "$SCRIPT"/logserver.sh
sed -i "s/@USERMAJ@/$USERMAJ/g;" "$SCRIPT"/logserver.sh
echo "ccze -h < /tmp/access.log > $RUTORRENT/logserver/access.html" >> "$SCRIPT"/logserver.sh

# config.php
mkdir "$RUTORRENT"/conf/users/"$USER"
FONCPHPCONF "$USER" "$PORT" "$USERMAJ"

# chroot user supplèmentaire
echo "Match User $USER
ChrootDirectory /home/$USER">> /etc/ssh/sshd_config

service ssh restart

## conf user seedbox-manager
cd "$SBM"/conf/users || exit
mkdir "$USER"
cp -f "$FILES"/sbm/config-user.ini "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/\"\/\"/\"\/home\/$USER\"/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/https:\/\/graph.domaine.fr/..\/graph\/$USER.php/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/RPC1/$USERMAJ/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/contact@mail.com/$EMAIL/g;" "$SBM"/conf/users/"$USER"/config.ini

# plugin.ini
cp "$FILES"/rutorrent/plugins.ini "$RUTORRENT"/conf/users/"$USER"/plugins.ini
echo "[linklogs]
enabled = no" >> "$RUTORRENT"/conf/users/"$USER"/plugins.ini

# permission
chown -R www-data:www-data "$SBM"/conf/users
chown -R www-data:www-data "$RUTORRENT"
chown -R "$USER":"$USER" /home/"$USER"
chown root:"$USER" /home/"$USER"
chmod 755 /home/"$USER"

# script rtorrent
FONCSCRIPTRT "$USER" 
service "$USER"-rtorrent start

# htpasswd
FONCHTPASSWD "$USER"

# configuration page index munin
FONCGRAPH "$USER"

# log users
echo "userlog">> "$RUTORRENT"/histo.log
sed -i "s/userlog/$USER:$PORT/g;" "$RUTORRENT"/histo.log

echo "" ; set "218" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""
set "182" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}"
set "184" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
set "186" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
set "188" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}" ; echo ""
fi
done

else

################################################
# lancement gestion des utilisateurs ruTorrent #
################################################

clear

# Contrôle installation
if [ ! -f "$RUTORRENT"/histo.log ]; then
	echo "" ; set "220" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
	set "222" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}" ; echo ""
	exit 1
fi

# message d'accueil
echo "" ; set "224" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""
# shellcheck source=/dev/null
. "$INCLUDES"/logo.sh

# mise en garde
echo "" ; set "226" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
set "228" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
set "230" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
echo "" ; set "232" ; FONCTXT "$1" ; echo -n -e "${CGREEN}$TXT1 ${CEND}"
read -r VALIDE

if FONCNO "$VALIDE"; then
	echo "" ; set "210" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
	echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}" ; echo ""
	exit 1
fi

if FONCYES "$VALIDE"; then

# Boucle ajout/suppression utilisateur
while :; do

# menu gestion multi-utilisateurs
echo "" ; set "234" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
set "236" "248" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
set "238" "250" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
set "240" "252" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
set "242" "254" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
set "244" "256" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
set "246" "258" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
set "260" ; FONCTXT "$1" ; echo -n -e "${CBLUE}$TXT1 ${CEND}"
read -r OPTION

case $OPTION in
1)

# demande nom et mot de passe
while :; do
set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
FONCUSER
done

echo ""
while :; do
set "112" "114" "116" ; FONCTXT "$1" "$2" "$3" ; echo -e "${CGREEN}$TXT1${CEND}${CYELLOW}$TXT2${CEND}${CGREEN}$TXT3${CEND}"
FONCPASS
done

# récupération 5% root sur /home/user si présent
FONCFSUSER "$USER"

# variable email (rétro compatible)
TESTMAIL=$(sed -n "1 p" "$RUTORRENT"/histo.log)
if [[ "$TESTMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]*$ ]]; then
        EMAIL="$TESTMAIL"
else
        EMAIL=contact@exemple.com
fi

# variable passe nginx
PASSNGINX=${USERPWD}

# ajout utilisateur
useradd -M -s /bin/bash "$USER"

# création du mot de passe pour cet utilisateur
echo "${USER}:${USERPWD}" | chpasswd

# anti-bug /home/user déjà existant
mkdir -p /home/"$USER"
chown -R "$USER":"$USER" /home/"$USER"

# variable utilisateur majuscule
USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

# récupération IP serveur
IP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ "$IP" = "" ]; then
	IP=$(wget -qO- ipv4.icanhazip.com)
fi

su "$USER" -c 'mkdir -p ~/watch ~/torrents ~/.session '

# calcul port
HISTO=$(wc -l < "$RUTORRENT"/histo.log)
PORT=$(( 5001+HISTO ))

# configuration munin
FONCMUNIN "$USER" "$PORT"

# config .rtorrent.rc
 FONCTORRENTRC "$USER" "$PORT" "$RUTORRENT"

# config user rutorrent.conf
sed -i '$d' "$NGINXENABLE"/rutorrent.conf
FONCRTCONF "$USERMAJ"  "$PORT" "$USER"

# logserver user config
sed -i '$d' "$SCRIPT"/logserver.sh
echo "sed -i '/@USERMAJ@\ HTTP/d' access.log" >> "$SCRIPT"/logserver.sh
sed -i "s/@USERMAJ@/$USERMAJ/g;" "$SCRIPT"/logserver.sh
echo "ccze -h < /tmp/access.log > $RUTORRENT/logserver/access.html" >> "$SCRIPT"/logserver.sh

# config.php
mkdir "$RUTORRENT"/conf/users/"$USER"
FONCPHPCONF "$USER" "$PORT" "$USERMAJ"

# plugin.ini
cp "$FILES"/rutorrent/plugins.ini "$RUTORRENT"/conf/users/"$USER"/plugins.ini
echo "[linklogs]
enabled = no" >> "$RUTORRENT"/conf/users/"$USER"/plugins.ini

# chroot user supplémentaire
echo "Match User $USER
ChrootDirectory /home/$USER">> /etc/ssh/sshd_config

service ssh restart

# permission
chown -R www-data:www-data "$RUTORRENT"
chown -R "$USER":"$USER" /home/"$USER"
chown root:"$USER" /home/"$USER"
chmod 755 /home/"$USER"

# script rtorrent
FONCSCRIPTRT "$USER" 
service "$USER"-rtorrent start

# htpasswd
FONCHTPASSWD "$USER"

# seedbox-manager conf user
cd "$SBM"/conf/users || exit
mkdir "$USER"
cp -f "$FILES"/sbm/config-user.ini "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/\"\/\"/\"\/home\/$USER\"/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/https:\/\/graph.domaine.fr/..\/graph\/$USER.php/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/RPC1/$USERMAJ/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/contact@mail.com/$EMAIL/g;" "$SBM"/conf/users/"$USER"/config.ini

chown -R www-data:www-data "$SBM"/conf/users

# configuration page index munin
FONCGRAPH "$USER"

# log users
echo "userlog">> "$RUTORRENT"/histo.log
sed -i "s/userlog/$USER:$PORT/g;" "$RUTORRENT"/histo.log

echo "" ; set "218" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""
set "182" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}"
set "184" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
set "186" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
set "188" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}" ; echo ""
;;

# suspendre utilisateur
2)

echo "" ; set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
read -r USER

# variable email (rétro compatible)
TESTMAIL=$(sed -n "1 p" "$RUTORRENT"/histo.log)
if [[ "$TESTMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]*$ ]]; then
        EMAIL="$TESTMAIL"
else
        EMAIL=contact@exemple.com
fi

# récupération IP serveur
IP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ "$IP" = "" ]; then
	IP=$(wget -qO- ipv4.icanhazip.com)
fi

# variable utilisateur majuscule
USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

echo "" ; set "262" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""

# crontab (pour retro-compatibilité)
crontab -l > /tmp/rmuser
sed -i "s/* \* \* \* \* if ! ( ps -U $USER | grep rtorrent > \/dev\/null ); then \/etc\/init.d\/$USER-rtorrent start; fi > \/dev\/null 2>&1//g;" /tmp/rmuser
crontab /tmp/rmuser
rm /tmp/rmuser

update-rc.d "$USER"-rtorrent remove

# contrôle présence utilitaire
if [ ! -f /var/www/base/aide/contact.html ]; then
	cd /tmp || exit
	wget http://www.bonobox.net/script/contact.tar.gz
	tar xzfv contact.tar.gz
	cp /tmp/contact/contact.html /var/www/base/aide/contact.html
	cp /tmp/contact/style/style.css /var/www/base/aide/style/style.css
fi

# page support
cp /var/www/base/aide/contact.html /var/www/base/"$USER".html
sed -i "s/@USER@/$USER/g;" /var/www/base/"$USER".html
chown -R www-data:www-data /var/www/base/"$USER".html

# Seedbox-Manager service minimum
mv "$SBM"/conf/users/"$USER"/config.ini "$SBM"/conf/users/"$USER"/config.bak
cp "$FILES"/sbm/config-mini.ini "$SBM"/conf/users/"$USER"/config.ini

sed -i "s/\"\/\"/\"\/home\/$USER\"/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/https:\/\/rutorrent.domaine.fr/..\/$USER.html/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/https:\/\/proxy.domaine.fr/..\/$USER.html/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/https:\/\/graph.domaine.fr/..\/$USER.html/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/RPC1/$USERMAJ/g;" "$SBM"/conf/users/"$USER"/config.ini
sed -i "s/contact@mail.com/$EMAIL/g;" "$SBM"/conf/users/"$USER"/config.ini

chown -R www-data:www-data "$SBM"/conf/users

# blocage proxy
echo "[linkproxy]
enabled = no">> "$RUTORRENT"/conf/users/"$USER"/plugins.ini

# stop user
/etc/init.d/"$USER"-rtorrent stop
killall --user "$USER" rtorrent
killall --user "$USER" screen

usermod -L "$USER"

echo "" ; set "264" "268" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
;;

# rétablir utilisateur
3)

echo "" ; set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}"
read -r USER
echo "" ; set "270" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""

# remove ancien script pour mise à jour init.d
update-rc.d "$USER"-rtorrent remove

# script rtorrent
FONCSCRIPTRT "$USER" 

# start user
 rm /home/"$USER"/.session/rtorrent.lock
 #su --command='screen -dmS "$USER"-rtorrent rtorrent' "$USER"
su --command="screen -dmS $USER-rtorrent rtorrent" "$USER"
usermod -U "$USER"

# retablisement proxy
sed -i '/linkproxy/,+1d' "$RUTORRENT"/conf/users/"$USER"/plugins.ini

# Seedbox-Manager service normal
rm "$SBM"/conf/users/"$USER"/config.ini
mv "$SBM"/conf/users/"$USER"/config.bak "$SBM"/conf/users/"$USER"/config.ini
chown -R www-data:www-data "$SBM"/conf/users
rm /var/www/base/"$USER".html

echo "" ; set "264" "272" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
;;

# modification mot de passe utilisateur
4)

echo "" ; set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
read -r USER
echo ""
while :; do
set "274" "114" "116" ; FONCTXT "$1" "$2" "$3" ; echo -e "${CGREEN}$TXT1${CEND}${CYELLOW}$TXT2${CEND}${CGREEN}$TXT3${CEND}"
FONCPASS
done

echo "" ; set "276" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""

# variable passe nginx
PASSNGINX=${USERPWD}

# modification du mot de passe pour cet utilisateur
echo "${USER}:${USERPWD}" | chpasswd

# htpasswd
FONCHTPASSWD "$USER"

echo "" ; set "278" "280" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
echo
set "182" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}"
set "184" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
set "186" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
set "188" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}" ; echo ""
;;

# suppression utilisateur
5)

echo "" ; set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
read -r USER
echo "" ; set "282" "284" ; FONCTXT "$1" "$2" ; echo -n -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CGREEN}$TXT2 ${CEND}"
read -r SUPPR

if FONCNO "$SUPPR"; then
	echo

else
	set "286" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""

	# variable utilisateur majuscule
	USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")
	echo -e "$USERMAJ"

	# suppression conf munin
	rm "$GRAPH"/img/rtom_"$USER"_*
	rm "$GRAPH"/"$USER".php

	sed -i "/rtom_${USER}_peers.graph_width 700/,+8d" /etc/munin/munin.conf
	sed -i "/\[rtom_${USER}_\*\]/,+6d" /etc/munin/plugin-conf.d/munin-node

	rm /etc/munin/plugins/rtom_"$USER"_*
	rm "$MUNIN"/rtom_"$USER"_*
	rm "$MUNINROUTE"/rtom_"$USER"_*

	/etc/init.d/munin-node restart

	# crontab (pour rétro-compatibilité)
	crontab -l > /tmp/rmuser
	sed -i "s/* \* \* \* \* if ! ( ps -U $USER | grep rtorrent > \/dev\/null ); then \/etc\/init.d\/$USER-rtorrent start; fi > \/dev\/null 2>&1//g;" /tmp/rmuser
	crontab /tmp/rmuser
	rm /tmp/rmuser

	# stop user
	/etc/init.d/"$USER"-rtorrent stop
	killall --user "$USER" rtorrent
	killall --user "$USER" screen

	# suppression script
	rm /etc/init.d/"$USER"-rtorrent
	update-rc.d "$USER"-rtorrent remove

	# suppression conf rutorrent
	rm -R "$RUTORRENT"/conf/users/"$USER"
	rm -R "$RUTORRENT"/share/users/"$USER"

	# suppression pass
	sed -i "/^$USER/d" "$NGINXPASS"/rutorrent_passwd
	rm "$NGINXPASS"/rutorrent_passwd_"$USER"

	# suppression nginx
	sed -i '/location \/'"$USERMAJ"'/,/}/d' "$NGINXENABLE"/rutorrent.conf
	service nginx restart

	# suppression seebbox-manager
	rm -R "$SBM"/conf/users/"$USER"

	# suppression user
	deluser "$USER" --remove-home

	echo "" ; set "264" "288" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
fi
;;

# sortir gestion utilisateurs
6)
echo "" ; set "290" ; FONCTXT "$1" ; echo -n -e "${CGREEN}$TXT1 ${CEND}"
read -r REBOOT

if FONCNO "$REBOOT"; then
	echo "" ; set "200" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
	echo "" ; set "210" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
	echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}" ; echo ""
	exit 1
fi

if FONCYES "$REBOOT" = "y"; then
	echo "" ; set "210" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
	echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}" ; echo ""
	reboot
fi

break
;;

*)
set "292" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
;;
esac
done
fi
fi
