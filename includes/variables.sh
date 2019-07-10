#!/bin/bash

# variables
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

ARG="$*"
VERSION=$(cat /etc/debian_version)

if [[ "$VERSION" = 8.* ]]; then
	DEBNUMBER="Debian_8.0.deb"
	DEBNAME="jessie"
	PHPPATH="/etc/php5"
	PHPNAME="php5"
	PHPSOCK="/var/run/php5-fpm.sock"
	LIBZEN0NAME="libzen0"
	LIBMEDIAINFO0NAME="libmediainfo0"

elif [[ "$VERSION" = 9.* ]]; then
	DEBNUMBER="Debian_9.0.deb"
	DEBNAME="stretch"
	PHPPATH="/etc/php/7.3"
	PHPNAME="php7.3"
	PHPSOCK="/run/php/php7.3-fpm.sock"
	LIBZEN0NAME="libzen0v5"
	LIBMEDIAINFO0NAME="libmediainfo0v5"
	
elif [[ "$VERSION" = 10.* ]]; then
	DEBNUMBER="Debian_10.0.deb"
	DEBNAME="buster"
	PHPPATH="/etc/php/7.3"
	PHPNAME="php7.3"
	PHPSOCK="/run/php/php7.3-fpm.sock"
	LIBZEN0NAME="libzen0v5"
	LIBMEDIAINFO0NAME="libmediainfo0v5"

fi

LIBTORRENT="v0.13.7"
RTORRENT="v0.9.7"

LIBZEN0="0.4.37"
LIBMEDIAINFO0="19.04"
MEDIAINFO="19.04"

RUTORRENT="/var/www/rutorrent"
RUPLUGINS="/var/www/rutorrent/plugins"
RUCONFUSER="/var/www/rutorrent/conf/users"
BONOBOX="/tmp/rutorrent-bonobox"
FILES="/tmp/rutorrent-bonobox/files"
SCRIPT="/usr/share/scripts-perso"
NGINX="/etc/nginx"
NGINXWEB="/var/www"
NGINXBASE="/var/www/base"
NGINXPASS="/etc/nginx/passwd"
NGINXENABLE="/etc/nginx/sites-enabled"
NGINXSSL="/etc/nginx/ssl"
NGINXCONFD="/etc/nginx/conf.d"
SOURCES="/etc/apt/sources.list.d"
ARGFILE="/tmp/arg.tmp"
ARGFTP=$(echo "$ARG" | tr -s ' ' '\n' | grep -m 1 ftp)
ARGREBOOT=$(echo "$ARG" | tr -s ' ' '\n' | grep -m 1 reboot)
WDATA="www-data:www-data"

RAPPORT="/tmp/rapport.txt"
NOYAU=$(uname -r)
DATE=$(date +"%d-%m-%Y à %H:%M")
NGINX_VERSION=$(2>&1 nginx -v | grep -Eo "[0-9.+]{1,}")
RUTORRENT_VERSION=$(grep version: < /var/www/rutorrent/js/webui.js | grep -E -o "[0-9]\.[0-9]{1,}")
RTORRENT_VERSION=$(rtorrent -h | grep -E -o "[0-9]\.[0-9].[0-9]{1,}")
PHP_VERSION=$(php -v | cut -c 1-7 | grep PHP | cut -c 5-7)
CPU=$(sed '/^$/d' < /proc/cpuinfo | grep -m 1 'model name' | cut -c14-)
PASTEBIN="paste.ubuntu.com"
