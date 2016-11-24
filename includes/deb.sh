#!/bin/bash

FONCDEP () {
	cat <<- EOF > "$SOURCES"/non-free.list
	#dépôt paquet propriétaire
	deb http://ftp2.fr.debian.org/debian/ $1 main non-free
	deb-src http://ftp2.fr.debian.org/debian/ $1 main non-free
	EOF

	cat <<- EOF > "$SOURCES"/nginx.list
	# dépôt nginx
	deb http://nginx.org/packages/debian/ $1 nginx
	deb-src http://nginx.org/packages/debian/ $1 nginx
	EOF

	# clés
	wget http://www.dotdeb.org/dotdeb.gpg
	apt-key add dotdeb.gpg

	wget http://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
}

# ajout dépôts
cd /tmp || exit

if [[ $VERSION =~ 7. ]]; then

	DEBNUMBER="Debian_7.0.deb"
	DEBNAME="wheezy"
	PHPPATH="/etc/php5"
	PHPNAME="php5"
	PHPSOCK="/var/run/php5-fpm.sock"

	cat <<- EOF > "$SOURCES"/dotdeb-php56.list
	# dépôt dotdeb php 5.6
	deb http://packages.dotdeb.org $DEBNAME-php56 all
	deb-src http://packages.dotdeb.org $DEBNAME-php56 all
	EOF

elif [[ $VERSION =~ 8. ]]; then
	# shellcheck disable=SC2034
	DEBNUMBER="Debian_8.0.deb"
	DEBNAME="jessie"
	#PHPPATH="/etc/php/7.0"
	#PHPNAME="php7.0"
	#PHPSOCK="/run/php/php7.0-fpm.sock"
	PHPPATH="/etc/php5"
	PHPNAME="php5"
	PHPSOCK="/var/run/php5-fpm.sock"

	cat <<- EOF > "$SOURCES"/dotdeb.list
	# dépôt dotdeb
	deb http://packages.dotdeb.org $DEBNAME all
	deb-src http://packages.dotdeb.org $DEBNAME all
	EOF

	cat <<- EOF > "$SOURCES"/multimedia.list
	# dépôt multimedia
	deb http://www.deb-multimedia.org $DEBNAME main non-free
	EOF

	# clé deb-multimedia.org
	apt-get update && apt-get install -y --force-yes deb-multimedia-keyring
	#wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_"$DEBMULTIMEDIA"_all.deb
	#dpkg -i deb-multimedia-keyring_"$DEBMULTIMEDIA"_all.deb

fi

# dépôts standard
FONCDEP "$DEBNAME"
