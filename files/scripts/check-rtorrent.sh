#!/bin/bash
#
# Debug ruTorrent
# Script original développé par BarracudaXT (BXT)
# Modification pour le script auto par ex_rat


# includes
INCLUDES="/tmp/rutorrent-bonobox/includes"
# shellcheck source=/dev/null
. "$INCLUDES"/variables.sh
# shellcheck source=/dev/null
. "$INCLUDES"/langues.sh
# shellcheck source=/dev/null
. "$INCLUDES"/functions.sh

FONCCONTROL
echo "";
set "266"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} "
set "214"; FONCTXT "$1"; echo -e -n "${CGREEN}$TXT1 :${CEND} "
read -r USERNAME

if [[ $(grep "$USERNAME:" -c /etc/shadow) != "1" ]]; then
	set "199"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
else
	FONCGEN ruTorrent "$USERNAME"
	FONCCHECKBIN pastebinit

	cat <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## Partition
		.......................................................................................................................................

	EOF
	df -h >> "$RAPPORT"

	FONCTESTRTORRENT

	cat <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## rTorrent Activity
		.......................................................................................................................................

	EOF

	echo -e "$(/bin/ps uU "$USERNAME" | grep -e rtorrent)" >> "$RAPPORT"

	cat <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## Irssi Activity
		.......................................................................................................................................

	EOF

	if ! [[ -f /etc/irssi.conf ]]; then
		echo -e "--> Irssi not installed" >> "$RAPPORT"
	else
		echo -e "$(/bin/ps uU "$USERNAME" | grep -e irssi)" >> "$RAPPORT"
	fi

	cat <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## .rtorrent.rc
		## File : /home/$USERNAME/.rtorrent.rc
		.......................................................................................................................................
	EOF
	echo "" >> "$RAPPORT"

	if ! [[ -f /home/"$USERNAME"/.rtorrent.rc ]]; then
		echo "--> File not found" >> "$RAPPORT"
	else
		cat "/home/$USERNAME/.rtorrent.rc" >> "$RAPPORT"
	fi

	cat <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## ruTorrent config.php $USERNAME
		## File : $RUTORRENT/conf/users/$USERNAME/config.php
		.......................................................................................................................................
	EOF
	echo "" >> "$RAPPORT"

	if [[ ! -f "$RUTORRENT"/conf/users/"$USERNAME"/config.php ]]; then
		echo "--> File not found" >> "$RAPPORT"
	else
		cat "$RUTORRENT"/conf/users/"$USERNAME"/config.php >> "$RAPPORT"
	fi

	FONCRAPPORT /etc/init.d/"$USERNAME"-rtorrent "$USERNAME"-rtorrent 1

	cd "$NGINXENABLE" || exit
	for VHOST in $(ls)
	do
		FONCRAPPORT "$NGINXENABLE"/"$VHOST" "$VHOST" 1
	done

	if [[ -f "$NGINXENABLE"/cakebox.conf ]]; then
		FONCRAPPORT /var/www/cakebox/config/"$USERNAME".php cakebox.config.php 1
	fi

	FONCRAPPORT /etc/nginx/nginx.conf nginx.conf 1

	cd /etc/nginx/conf.d || exit
	for CONF_D in $(ls)
	do
		FONCRAPPORT /etc/nginx/conf.d/"$CONF_D" "$CONF_D" 1
	done

	cat <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## files pass nginx
		## Dir : /etc/nginx/passwd
		.......................................................................................................................................
	EOF
	echo "" >> "$RAPPORT"

	cd /etc/nginx/passwd || exit
	for PASS in $(ls)
	do
		echo "$PASS" >> "$RAPPORT"
	done

	cat <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## files ssl nginx
		## Dir : /etc/nginx/ssl
		.......................................................................................................................................
	EOF
	echo "" >> "$RAPPORT"

	cd /etc/nginx/ssl || exit
	for SSL in $(ls)
	do
		echo "$SSL" >> "$RAPPORT"
	done

	FONCRAPPORT /var/log/nginx/rutorrent-error.log nginx.log 1

	cat <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## end
		.......................................................................................................................................
	EOF

	FONCGENRAPPORT
	echo ""
fi
