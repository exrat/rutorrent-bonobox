#!/bin/bash

FONCDEP () {
	"$CMDCAT" <<- EOF > "$SOURCES"/non-free.list
		# dépôt paquets propriétaires
		deb http://ftp2.fr.debian.org/debian/ $1 main non-free
	EOF

	"$CMDCAT" <<- EOF > "$SOURCES"/nginx.list
		# dépôt nginx
		deb http://nginx.org/packages/debian/ $1 nginx
		deb-src http://nginx.org/packages/debian/ $1 nginx
	EOF

	"$CMDCAT" <<- EOF > "$SOURCES"/multimedia.list
		# dépôt multimedia
		deb http://www.deb-multimedia.org $1 main non-free
	EOF

	"$CMDCAT" <<- EOF > "$SOURCES"/sury-php.list
		# dépôt sury php 7.3
		deb https://packages.sury.org/php/ $1 main
	EOF

	# clés
	"$CMDWGET" https://packages.sury.org/php/apt.gpg -O sury.gpg && "$CMDAPTKEY" add sury.gpg 2>/dev/null

	"$CMDWGET" http://nginx.org/keys/nginx_signing.key && "$CMDAPTKEY" add nginx_signing.key 2>/dev/null

	"$CMDAPTGET" update -oAcquire::AllowInsecureRepositories=true && "$CMDAPTGET" install -y --allow-unauthenticated deb-multimedia-keyring
}

# dépôts standard
cd /tmp || exit
"$CMDAPTGET" install -y apt-transport-https gnupg2
FONCDEP "$DEBNAME"
