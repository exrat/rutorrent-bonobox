#!/bin/bash

FONCDEP () {
	cat <<- EOF > "$SOURCES"/non-free.list
		# dépôt paquets propriétaires
		deb http://ftp2.fr.debian.org/debian/ $1 main non-free
		deb-src http://ftp2.fr.debian.org/debian/ $1 main non-free
	EOF

	cat <<- EOF > "$SOURCES"/nginx.list
		# dépôt nginx
		deb http://nginx.org/packages/debian/ $1 nginx
		deb-src http://nginx.org/packages/debian/ $1 nginx
	EOF

	cat <<- EOF > "$SOURCES"/multimedia.list
		# dépôt multimedia
		deb http://www.deb-multimedia.org $1 main non-free
	EOF

	# clés
	wget http://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg 2>/dev/null

	wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key 2>/dev/null
}

# dépôts standard
cd /tmp || exit
FONCDEP "$DEBNAME"

if [[ "$VERSION" = 7.* ]]; then
	cat <<- EOF > "$SOURCES"/dotdeb-php56.list
		# dépôt dotdeb php 5.6
		deb http://packages.dotdeb.org $DEBNAME-php56 all
		deb-src http://packages.dotdeb.org $DEBNAME-php56 all
	EOF

	# clé deb-multimedia.org
	apt-get update && apt-get install -y --force-yes deb-multimedia-keyring

elif [[ "$VERSION" = 8.* ]]; then
	cat <<- EOF > "$SOURCES"/dotdeb.list
		# dépôt dotdeb
		deb http://packages.dotdeb.org $DEBNAME all
		deb-src http://packages.dotdeb.org $DEBNAME all
	EOF

	# clé deb-multimedia.org
	apt-get update && apt-get install -y --force-yes deb-multimedia-keyring

elif [[ "$VERSION" = 9.* ]]; then
	apt-get install -y apt-transport-https

	# clé sury.org
	wget https://packages.sury.org/php/apt.gpg -O sury.gpg && apt-key add sury.gpg 2>/dev/null

	cat <<- EOF > "$SOURCES"/sury-php.list
		# dépôt sury php 7.1
		deb https://packages.sury.org/php/ $DEBNAME main
	EOF

	# clé deb-multimedia.org
	apt-get update && apt-get install -y --allow-unauthenticated deb-multimedia-keyring
fi
