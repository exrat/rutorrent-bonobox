#!/bin/bash

# variables
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

ARG="$*"
VERSION=$("$CMDCAT" /etc/debian_version)

if [[ "$VERSION" = 10.* ]]; then
	DEBNUMBER="Debian_10.0.deb"
	DEBNAME="buster"

elif [[ "$VERSION" = 11.* ]]; then
	DEBNUMBER="Debian_11.0.deb"
	DEBNAME="bullseye"
fi

HISTOLOG="histo-2022"
PHPNAME="php7.4"
PHPPATH="/etc/php/7.4"
PHPSOCK="/run/php/php7.4-fpm.sock"
#LIBZEN0NAME="libzen0v5"
#LIBMEDIAINFO0NAME="libmediainfo0v5"

LIBTORRENT="v0.13.8"
RTORRENT="v0.9.8"

#LIBZEN0="0.4.37"
#LIBMEDIAINFO0="19.04"
#MEDIAINFO="19.04"

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
ARGFTP=$("$CMDECHO" "$ARG" | "$CMDTR" -s ' ' '\n' | "$CMDGREP" -m 1 ftp)
ARGREBOOT=$("$CMDECHO" "$ARG" | "$CMDTR" -s ' ' '\n' | "$CMDGREP" -m 1 reboot)
WDATA="www-data:www-data"

RAPPORT="/tmp/rapport.txt"
NOYAU=$("$CMDUNAME" -r)
DATE=$("$CMDDATE" +"%d-%m-%Y à %H:%M")
NGINX_VERSION=$(2>&1 "$CMDNGINX" -v | "$CMDGREP" -Eo "[0-9.+]{1,}")
RUTORRENT_VERSION=$("$CMDGREP" version: < /var/www/rutorrent/js/webui.js | "$CMDGREP" -E -o "[0-9]\.[0-9]{1,}")
RTORRENT_VERSION=$("$CMDRTORRENT" -h | "$CMDGREP" -E -o "[0-9]\.[0-9].[0-9]{1,}")
PHP_VERSION=$("$CMDPHP" -v | "$CMDCUT" -c 1-7 | "$CMDGREP" PHP | "$CMDCUT" -c 5-7)
CPU=$("$CMDSED" '/^$/d' < /proc/cpuinfo | "$CMDGREP" -m 1 'model name' | "$CMDCUT" -c14-)
PASTEBIN="paste.ubuntu.com"
