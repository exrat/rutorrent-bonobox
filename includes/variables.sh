#!/bin/bash

# variables
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

VERSION=$(cat /etc/debian_version)
LIBTORRENT="0.13.6"
RTORRENT="0.9.6"
DEBMULTIMEDIA="2016.3.7"
NVM="0.31.0"
NODE="5.3.0"

RUTORRENT="/var/www/rutorrent"
BONOBOX="/tmp/rutorrent-bonobox"
GRAPH="/var/www/graph"
MUNIN="/usr/share/munin/plugins"
MUNINROUTE="/var/www/monitoring/localdomain/localhost.localdomain"
FILES="/tmp/rutorrent-bonobox/files"
SCRIPT="/usr/share/scripts-perso"
SBM="/var/www/seedbox-manager"
NGINX="/etc/nginx"
NGINXWEB="/var/www"
NGINXBASE="/var/www/base"
NGINXPASS="/etc/nginx/passwd"
NGINXENABLE="/etc/nginx/sites-enabled"
NGINXSSL="/etc/nginx/ssl"
NGINXCONFD="/etc/nginx/conf.d"

