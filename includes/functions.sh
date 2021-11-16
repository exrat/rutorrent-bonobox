#!/bin/bash

FONCCONTROL () {
	if [[ $("$CMDUNAME" -m) == x86_64 ]] && [[ "$VERSION" = 10.* ]] || [[ "$VERSION" = 11.* ]]; then
		if [ "$("$CMDID" -u)" -ne 0 ]; then
			"$CMDECHO" ""; set "100"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"; "$CMDECHO" ""
			exit 1
		fi
	else
		"$CMDECHO" ""; set "130"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"; "$CMDECHO" ""
		exit 1
	fi
}

FONCBASHRC () {
	unalias cp 2>/dev/null
	unalias rm 2>/dev/null
	unalias mv 2>/dev/null
	export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

FONCUSER () {
	while :; do
		set "214"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
		read -r TESTUSER
		"$CMDGREP" -w "$TESTUSER" /etc/passwd &> /dev/null
		if [ $? -eq 1 ]; then
			if [[ "$TESTUSER" =~ ^[a-z0-9]{3,}$ ]]; then
				USER="$TESTUSER"
				# shellcheck disable=SC2104
				break
			else
				"$CMDECHO" ""; set "110"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"; "$CMDECHO" ""
			fi
		else
			"$CMDECHO" ""; set "198"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"; "$CMDECHO" ""
		fi
	done
}

FONCPASS () {
	while :; do
		set "112" "114" "116"; FONCTXT "$1" "$2" "$3"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$TXT2${CEND} ${CGREEN}$TXT3 ${CEND}"
		read -r REPPWD
		if [ "$REPPWD" = "" ]; then
			AUTOPWD=$("$CMDTR" -dc "1-9a-nA-Np-zP-Z" < /dev/urandom | "$CMDHEAD" -c 8)
			"$CMDECHO" ""; set "118" "120"; FONCTXT "$1" "$2"; "$CMDECHO"  -n -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$AUTOPWD${CEND} ${CGREEN}$TXT2 ${CEND}"
			read -r REPONSEPWD
			if FONCNO "$REPONSEPWD"; then
				"$CMDECHO"
			else
				USERPWD="$AUTOPWD"
				# shellcheck disable=SC2104
				break
			fi
		else
			if [[ "$REPPWD" =~ ^[a-zA-Z0-9]{6,}$ ]]; then
				# shellcheck disable=SC2034
				USERPWD="$REPPWD"
				# shellcheck disable=SC2104
				break
			else
				"$CMDECHO" ""; set "122"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"; "$CMDECHO" ""
			fi
		fi
	done
}

FONCIP () {
	"$CMDAPTGET" install -y net-tools
	IP=$("$CMDIP" -4 addr | "$CMDGREP" "inet" | "$CMDGREP" -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | "$CMDAWK" '{print $2}' | "$CMDCUT" -d/ -f1)

	if [ "$IP" = "" ]; then
		IP=$("$CMDWGET" -qO- ipv4.icanhazip.com)
			if [ "$IP" = "" ]; then
				IP=$("$CMDWGET" -qO- ipv4.ratbox.nl)
				if [ "$IP" = "" ]; then
					IP=x.x.x.x
				fi
			fi
	fi
}

FONCPORT () {
	HISTO=$("$CMDWC" -l < "$RUTORRENT"/"$HISTOLOG".log)
	# shellcheck disable=SC2034
	PORT=$(( 5001+HISTO ))
}

FONCYES () {
	[ "$1" = "y" ] || [ "$1" = "Y" ] || [ "$1" = "o" ] || [ "$1" = "O" ] || [ "$1" = "j" ] || [ "$1" = "J" ] || [ "$1" = "д" ] || [ "$1" = "s" ] || [ "$1" = "S" ]
}

FONCNO () {
	[ "$1" = "n" ] || [ "$1" = "N" ] || [ "$1" = "h" ] || [ "$1" = "H" ]
}

FONCTXT () {
	TXT1="$("$CMDGREP" "$1" "$BONOBOX"/lang/"$GENLANG".lang | "$CMDCUT" -c5-)"
	TXT2="$("$CMDGREP" "$2" "$BONOBOX"/lang/"$GENLANG".lang | "$CMDCUT" -c5-)"
	# shellcheck disable=SC2034
	TXT3="$("$CMDGREP" "$3" "$BONOBOX"/lang/"$GENLANG".lang | "$CMDCUT" -c5-)"
}

FONCSERVICE () {
	"$CMDSYSTEMCTL" "$1" "$2".service
}
# FONCSERVICE $1 {start/stop/restart} $2 {nom service}

FONCFSUSER () {
	FSUSER=$("$CMDGREP" /home/"$1" /etc/fstab | "$CMDCUT" -c 6-9)
	if [ "$FSUSER" = "" ]; then
		"$CMDECHO"
	else
		"$CMDTUNE2FS" -m 0 /dev/"$FSUSER" &> /dev/null
		"$CMDMOUNT" -o remount /home/"$1" &> /dev/null
	fi
}

FONCHTPASSWD () {
	"$CMDHTPASSWD" -bs "$NGINXPASS"/rutorrent_passwd "$1" "${PASSNGINX}"
	"$CMDHTPASSWD" -cbs "$NGINXPASS"/rutorrent_passwd_"$1" "$1" "${PASSNGINX}"
	"$CMDCHMOD" 640 "$NGINXPASS"/*
	"$CMDCHOWN" -c "$WDATA" "$NGINXPASS"/*
}

FONCRTCONF () {
	"$CMDCAT" <<- EOF >> "$NGINXENABLE"/rutorrent.conf

		        location /$1 {
		                include scgi_params;
		                scgi_pass 127.0.0.1:$2;
		                auth_basic "Restricted";
		                auth_basic_user_file "$NGINXPASS/rutorrent_passwd_$3";
		        }
		}
	EOF

	if [ -f "$NGINXCONFD"/log_rutorrent.conf ]; then
		"$CMDSED" -i "2i\  /$USERMAJ 0;" "$NGINXCONFD"/log_rutorrent.conf
	fi
}

FONCPHPCONF () {
	"$CMDTOUCH" "$RUCONFUSER"/"$1"/config.php

	"$CMDCAT" <<- EOF > "$RUCONFUSER"/"$1"/config.php
		<?php
		\$pathToExternals = array(
		    "curl"   => '/usr/bin/curl',
		    "stat"   => '/usr/bin/stat',
		    "php"    => '/usr/bin/@PHPNAME@',
		    "pgrep"  => '/usr/bin/pgrep',
		    "python" => '/usr/bin/python3'
		    );
		\$topDirectory = '/home/$1';
		\$scgi_port = $2;
		\$scgi_host = '127.0.0.1';
		\$XMLRPCMountPoint = '/$3';
	EOF

	"$CMDSED" -i "s/@PHPNAME@/$PHPNAME/g;" "$RUCONFUSER"/"$1"/config.php
}

FONCTORRENTRC () {
	"$CMDCP" -f "$FILES"/rutorrent/rtorrent.rc /home/"$1"/.rtorrent.rc
	"$CMDSED" -i "s/@USER@/$1/g;" /home/"$1"/.rtorrent.rc
	"$CMDSED" -i "s/@PORT@/$2/g;" /home/"$1"/.rtorrent.rc
	"$CMDSED" -i "s|@RUTORRENT@|$3|;" /home/"$1"/.rtorrent.rc
}

FONCSCRIPTRT () {
	"$CMDCP" -f "$FILES"/rutorrent/init.conf /etc/init.d/"$1"-rtorrent
	"$CMDSED" -i "s/@USER@/$1/g;" /etc/init.d/"$1"-rtorrent
	"$CMDCHMOD" +x /etc/init.d/"$1"-rtorrent
	"$CMDUPDATERC" "$1"-rtorrent defaults
}

FONCBAKSESSION () {
	"$CMDSED" -i '$d' "$SCRIPT"/backup-session.sh

	"$CMDCAT" <<- EOF >> "$SCRIPT"/backup-session.sh
		FONCBACKUP $USER
		exit 0
	EOF
}

FONCGEN () {
	if [[ -f "$RAPPORT" ]]; then
		"$CMDRM" "$RAPPORT"
	fi
	"$CMDTOUCH" "$RAPPORT"

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		### Report generated on $DATE ###

		User ruTorrent --> $USERNAME
		Debian : $VERSION
		Kernel : $NOYAU
		CPU : $CPU
		nGinx : $NGINX_VERSION
		ruTorrent : $RUTORRENT_VERSION
		rTorrent : $RTORRENT_VERSION
		PHP : $PHP_VERSION
	EOF
}

FONCCHECKBIN () {
	if hash "$1" 2>/dev/null; then
		"$CMDECHO"
	else
		"$CMDAPTGET" -y install "$1"
		"$CMDECHO" ""
	fi
}

FONCGENRAPPORT () {
	LINK=$("$CMDPASTEBINIT" -b "$PASTEBIN" "$RAPPORT" 2>/dev/null)
	"$CMDECHO" -e "${CBLUE}Report link:${CEND} ${CYELLOW}$LINK${CEND}"
	"$CMDECHO" -e "${CBLUE}Report backup:${CEND} ${CYELLOW}$RAPPORT${CEND}"
}

FONCRAPPORT () {
	# $1 = Fichier
	if ! [[ -z "$1" ]]; then
		if [[ -f "$1" ]]; then
			if [[ $("$CMDWC" -l < "$1") == 0 ]]; then
				FILE="--> Empty file"
			else
				FILE=$("$CMDCAT" "$1")
				# domain.tld
				if [[ "$1" = /etc/nginx/sites-enabled/* ]]; then
					SERVER_NAME=$("$CMDGREP" server_name < "$1" | "$CMDCUT" -d';' -f1 | "$CMDSED" 's/ //' | "$CMDCUT" -c13-)
					LETSENCRYPT=$("$CMDGREP" letsencrypt < "$1" | "$CMDHEAD" -1 | "$CMDCUT" -f 5 -d '/')
					if ! [[ "$SERVER_NAME" = _ ]]; then
						if [ -z "$LETSENCRYPT" ]; then
							FILE=$("$CMDSED" "s/server_name[[:blank:]]${SERVER_NAME};/server_name domain.tld;/g;" "$1")
						else
							FILE=$("$CMDSED" "s/server_name[[:blank:]]${SERVER_NAME};/server_name domain.tld;/g; s/$LETSENCRYPT/domain.tld/g;" "$1")
						fi
					fi
				fi
			fi
		else
			FILE="--> Invalid File"
		fi
	else
		FILE="--> Invalid File"
	fi

	# $2 = Nom à afficher
	if [[ -z $2 ]]; then
		NAME="No name given"
	else
		NAME=$2
	fi

	# $3 = Affichage "$CMDHEAD"er
	if [[ $3 == 1 ]]; then
		"$CMDCAT" <<-EOF >> "$RAPPORT"

			.......................................................................................................................................
			## $NAME
			## File : $1
			.......................................................................................................................................
		EOF

		"$CMDCAT" <<-EOF >> "$RAPPORT"

			$FILE
		EOF
	fi
}

FONCTESTRTORRENT () {
	SCGI="$("$CMDSED" -n '/^network.scgi.open_port/p' /home/"$USERNAME"/.rtorrent.rc | "$CMDCUT" -b 36-)"
	PORT_LISTENING=$("$CMDNETSTAT" -aultnp | "$CMDAWK" '{print $4}' | "$CMDGREP" -E ":$SCGI\$" -c)
	RTORRENT_LISTENING=$("$CMDNETSTAT" -aultnp | "$CMDSED" -n '/'$SCGI'/p' | "$CMDGREP" rtorrent -c)

	"$CMDCAT" <<-EOF >> "$RAPPORT"

		.......................................................................................................................................
		## Check rTorrent & sgci
		.......................................................................................................................................

	EOF

	# rTorrent lancé
	if [[ "$("$CMDPS" uU "$USERNAME" | "$CMDGREP" -e 'rtorrent' -c)" == [0-1] ]]; then
		"$CMDECHO" -e "rTorrent down" >> "$RAPPORT"
	else
		"$CMDECHO" -e "rTorrent Up" >> "$RAPPORT"
	fi

	# socket
	if (( PORT_LISTENING >= 1 )); then
		"$CMDECHO" -e "A socket listens on the port $SCGI" >> "$RAPPORT"
		if (( RTORRENT_LISTENING >= 1 )); then
			"$CMDECHO" -e "It is well rTorrent that listens on the port $SCGI" >> "$RAPPORT"
		else
			"$CMDECHO" -e "It's not rTorrent listening on the port $SCGI" >> "$RAPPORT"
		fi
	else
		"$CMDECHO" -e "No program listening on the port $SCGI" >> "$RAPPORT"
	fi

	# ruTorrent
	if [[ -f "$RUTORRENT"/conf/users/"$USERNAME"/config.php ]]; then
		if [[ $("$CMDCAT" "$RUTORRENT"/conf/users/"$USERNAME"/config.php) =~ "\$scgi_port = $SCGI" ]]; then
			"$CMDECHO" -e "Good SCGI port specified in the config.php file" >> "$RAPPORT"
		else
			"$CMDECHO" -e "Wrong SCGI port specified in config.php" >> "$RAPPORT"
		fi
	else
		"$CMDECHO" -e "User directory found but config.php file does not exist" >> "$RAPPORT"
	fi

	# nginx
	if [[ $("$CMDCAT" "$NGINXENABLE"/rutorrent.conf) =~ $SCGI ]]; then
		"$CMDECHO" -e "The ports nginx and the one indicated match" >> "$RAPPORT"
	else
		"$CMDECHO" -e "The nginx ports and the specified ports do not match" >> "$RAPPORT"
	fi
}

FONCARG () {
	USER=$("$CMDGREP" -m 1 : < "$ARGFILE" | "$CMDCUT" -f 1 -d ':')
	USERPWD=$("$CMDGREP" -m 1 : < "$ARGFILE" | "$CMDCUT" -d ':' -f2-)
	"$CMDSED" -i '1d' "$ARGFILE"
}
