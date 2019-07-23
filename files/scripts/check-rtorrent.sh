#!/bin/bash
#
# Debug ruTorrent
# Script original développé par BarracudaXT (BXT)
# Modification pour le script auto par ex_rat


# includes
INCLUDES="/tmp/rutorrent-bonobox/includes"
# shellcheck source=/dev/null
. "$INCLUDES"/cmd.sh
# shellcheck source=/dev/null
. "$INCLUDES"/variables.sh
# shellcheck source=/dev/null
. "$INCLUDES"/langues.sh
# shellcheck source=/dev/null
. "$INCLUDES"/functions.sh

FONCCONTROL
"$CMDECHO" "";
set "266"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} "
set "214"; FONCTXT "$1"; "$CMDECHO" -e -n "${CGREEN}$TXT1 ${CEND} "
read -r USERNAME

if [[ $("$CMDGREP" "$USERNAME:" -c /etc/shadow) != "1" ]]; then
	set "199"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
else
	FONCGEN ruTorrent "$USERNAME"
	FONCCHECKBIN pastebinit

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## Partitions & Droits
		.......................................................................................................................................

	EOF
	"$CMDDF" -h >> "$RAPPORT"

	"$CMDECHO" "" >> $RAPPORT
	"$CMDSTAT" -c "%a %U:%G %n" /home/"$USERNAME" >> $RAPPORT
	for CHECK in '.autodl' '.backup-session' '.irssi' '.rtorrent.rc' '.session' 'torrents' 'watch'; do
		"$CMDSTAT" -c "%a %U:%G %n" /home/"$USERNAME"/"$CHECK" >> $RAPPORT
	done

	FONCTESTRTORRENT

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## rTorrent Activity
		.......................................................................................................................................

	EOF

	"$CMDECHO" -e "$("$CMDPS" uU "$USERNAME" | "$CMDGREP" -e rtorrent)" >> "$RAPPORT"

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## Irssi Activity
		.......................................................................................................................................

	EOF

	if ! [[ -f /etc/irssi.conf ]]; then
		"$CMDECHO" -e "--> Irssi not installed" >> "$RAPPORT"
	else
		"$CMDECHO" -e "$("$CMDPS" uU "$USERNAME" | "$CMDGREP" -e irssi)" >> "$RAPPORT"
	fi

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## .rtorrent.rc
		## File : /home/$USERNAME/.rtorrent.rc
		.......................................................................................................................................
	EOF
	"$CMDECHO" "" >> "$RAPPORT"

	if ! [[ -f /home/"$USERNAME"/.rtorrent.rc ]]; then
		"$CMDECHO" "--> File not found" >> "$RAPPORT"
	else
		"$CMDCAT" "/home/$USERNAME/.rtorrent.rc" >> "$RAPPORT"
	fi

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## ruTorrent /filemanager/conf.php
		## File : $RUPLUGINS/filemanager/conf.php
		.......................................................................................................................................
	EOF
	"$CMDECHO" "" >> "$RAPPORT"

	if [[ ! -f "$RUPLUGINS/filemanager/conf.php" ]]; then
		"$CMDECHO" "--> Fichier introuvable" >> "$RAPPORT"
	else
		"$CMDCAT" "$RUPLUGINS"/filemanager/conf.php >> "$RAPPORT"
	fi

	"$CMDCAT" <<-EOF >> $RAPPORT

		.......................................................................................................................................
		## ruTorrent /create/conf.php
		## File : $RUPLUGINS/create/conf.php
		.......................................................................................................................................
	EOF

	"$CMDECHO" "" >> "$RAPPORT"

	if [[ ! -f "$RUPLUGINS/create/conf.php" ]]; then
		"$CMDECHO" "--> Fichier introuvable" >> $RAPPORT
	else
		"$CMDCAT" "$RUPLUGINS"/create/conf.php >> "$RAPPORT"
	fi

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## ruTorrent config.php $USERNAME
		## File : $RUCONFUSER/$USERNAME/config.php
		.......................................................................................................................................
	EOF
	"$CMDECHO" "" >> "$RAPPORT"

	if [[ ! -f "$RUCONFUSER"/"$USERNAME"/config.php ]]; then
		"$CMDECHO" "--> File not found" >> "$RAPPORT"
	else
		"$CMDCAT" "$RUCONFUSER"/"$USERNAME"/config.php >> "$RAPPORT"
	fi

	FONCRAPPORT /etc/init.d/"$USERNAME"-rtorrent "$USERNAME"-rtorrent 1

	cd "$NGINXENABLE" || exit
	for VHOST in $("$CMDLS")
	do
		FONCRAPPORT "$NGINXENABLE"/"$VHOST" "$VHOST" 1
	done

	if [[ -f "$NGINXENABLE"/cakebox.conf ]]; then
		FONCRAPPORT "$NGINXWEB"/cakebox/config/"$USERNAME".php cakebox.config.php 1
	fi

	FONCRAPPORT "$NGINX"/nginx.conf nginx.conf 1

	cd "$NGINXCONFD" || exit
	for CONF_D in $("$CMDLS")
	do
		FONCRAPPORT "$NGINXCONFD"/"$CONF_D" "$CONF_D" 1
	done

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## files pass nginx
		## Dir : $NGINXPASS
		.......................................................................................................................................
	EOF
	"$CMDECHO" "" >> "$RAPPORT"

	cd "$NGINXPASS" || exit
	"$CMDSTAT" -c "%a %U:%G %n" * >> $RAPPORT

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## files ssl nginx
		## Dir : $NGINXSSL
		.......................................................................................................................................
	EOF
	"$CMDECHO" "" >> "$RAPPORT"

	cd "$NGINXSSL" || exit
	for SSL in $("$CMDLS")
	do
		"$CMDECHO" "$SSL" >> "$RAPPORT"
	done

	FONCRAPPORT /var/log/nginx/rutorrent-error.log nginx.log 1

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## end
		.......................................................................................................................................
	EOF

	FONCGENRAPPORT
	"$CMDECHO" ""
fi
