#!/bin/bash

FONCDEP () {
	cat <<- EOF > "$SOURCES"/non-free.list
		# dépôt paquets propriétaires
		deb http://ftp2.fr.debian.org/debian/ $1 main non-free
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

	cat <<- EOF > "$SOURCES"/sury-php.list
		# dépôt sury php 7.3
		deb https://packages.sury.org/php/ $1 main
	EOF

	cat <<- EOF > "$SOURCES"/mediainfo.list
		# dépôt mediainfo
		deb http://mediaarea.net/repo/deb/debian/ $1 main
	EOF

	# clés
	/usr/bin/wget https://packages.sury.org/php/apt.gpg -O sury.gpg && apt-key add sury.gpg 2>/dev/null

	/usr/bin/wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key 2>/dev/null

	/usr/bin/wget http://mediaarea.net/repo/deb/debian/pubkey.gpg -O mediainfo.gpg && apt-key add mediainfo.gpg 2>/dev/null

	apt-get update -oAcquire::AllowInsecureRepositories=true && apt-get install -y --allow-unauthenticated deb-multimedia-keyring
	#apt-get update && apt-get install -y --allow-unauthenticated deb-multimedia-keyring
}

# dépôts standard
cd /tmp || exit
apt-get install -y apt-transport-https gnupg2
FONCDEP "$DEBNAME"
