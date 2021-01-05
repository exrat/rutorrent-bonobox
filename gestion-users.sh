#!/bin/bash

################################################
# lancement gestion des utilisateurs ruTorrent #
################################################


# contrôle installation
if [ ! -f "$RUTORRENT"/"$HISTOLOG".log ]; then
	"$CMDECHO" ""; set "220"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
	set "222"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"; "$CMDECHO" ""
	exit 1
fi

# message d'accueil
"$CMDCLEAR"
"$CMDECHO" ""; set "224"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""
# shellcheck source=/dev/null
. "$INCLUDES"/logo.sh

# mise en garde
"$CMDECHO" ""; set "226"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
set "228"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
set "230"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
"$CMDECHO" ""; set "232"; FONCTXT "$1"; "$CMDECHO" -n -e "${CGREEN}$TXT1 ${CEND}"
read -r VALIDE

if FONCNO "$VALIDE"; then
	"$CMDECHO" ""; set "210"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"
	"$CMDECHO" -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; "$CMDECHO" ""
	exit 1
fi

if FONCYES "$VALIDE"; then
	# boucle ajout/suppression utilisateur
	while :; do
		# menu gestion multi-utilisateurs
		"$CMDECHO" ""; set "234"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"
		set "236" "248"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "238" "254"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "240" "256"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "242" "296"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "244" "258"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "260"; FONCTXT "$1"; "$CMDECHO" -n -e "${CBLUE}$TXT1 ${CEND}"
		read -r OPTION

		case $OPTION in
			1) # ajout utilisateur
				FONCUSER # demande nom user
				"$CMDECHO" ""
				FONCPASS # demande mot de passe

				# récupération 5% root sur /home/user si présent
				FONCFSUSER "$USER"

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# ajout utilisateur
				"$CMDUSERADD" -M -s /bin/bash "$USER"

				# création mot de passe utilisateur
				"$CMDECHO" "${USER}:${USERPWD}" | "$CMDCHPASSWD"

				# anti-bug /home/user déjà existant
				"$CMDMKDIR" -p /home/"$USER"
				"$CMDCHOWN" -R "$USER":"$USER" /home/"$USER"

				# variable utilisateur majuscule
				USERMAJ=$("$CMDECHO" "$USER" | "$CMDTR" "[:lower:]" "[:upper:]")

				# récupération ip serveur
				FONCIP
				"$CMDSU" "$USER" -c ""$CMDMKDIR" -p ~/watch ~/torrents ~/.session ~/.backup-session"

				# calcul port
				FONCPORT

				# configuration .rtorrent.rc
				FONCTORRENTRC "$USER" "$PORT" "$RUTORRENT"

				# configuration user rutorrent.conf
				"$CMDSED" -i '$d' "$NGINXENABLE"/rutorrent.conf
				FONCRTCONF "$USERMAJ"  "$PORT" "$USER"

				# configuration script backup .session (retro-compatible)
				if [ -f "$SCRIPT"/backup-session.sh ]; then
					FONCBAKSESSION
				fi

				# config.php
				"$CMDMKDIR" "$RUCONFUSER"/"$USER"
				FONCPHPCONF "$USER" "$PORT" "$USERMAJ"

				# plugins.ini
				"$CMDCP" -f "$FILES"/rutorrent/plugins.ini "$RUCONFUSER"/"$USER"/plugins.ini

				# chroot user supplémentaire
				"$CMDCAT" <<- EOF >> /etc/ssh/sshd_config
					Match User $USER
					ChrootDirectory /home/$USER
				EOF

				FONCSERVICE restart ssh

				# permissions
				"$CMDCHOWN" -R "$WDATA" "$RUTORRENT"
				"$CMDCHOWN" -R "$USER":"$USER" /home/"$USER"
				"$CMDCHOWN" root:"$USER" /home/"$USER"
				"$CMDCHMOD" 755 /home/"$USER"

				# script rtorrent
				FONCSCRIPTRT "$USER"

				# htpasswd
				FONCHTPASSWD "$USER"

				# lancement user
				FONCSERVICE start "$USER"-rtorrent

				# log users
				"$CMDECHO" "userlog">> "$RUTORRENT"/"$HISTOLOG".log
				"$CMDSED" -i "s/userlog/$USER:$PORT/g;" "$RUTORRENT"/"$HISTOLOG".log
				FONCSERVICE restart nginx
				"$CMDECHO" ""; set "218"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""
				set "182"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"
				set "184"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"; "$CMDECHO" ""
			;;

			2) # modification mot de passe utilisateur
				"$CMDECHO" ""; set "214"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				"$CMDECHO" ""; FONCPASS

				"$CMDECHO" ""; set "276"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# modification du mot de passe
				"$CMDECHO" "${USER}:${USERPWD}" | "$CMDCHPASSWD"

				# htpasswd
				FONCHTPASSWD "$USER"

				"$CMDECHO" ""; set "278" "280"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				"$CMDECHO"
				set "182"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"
				set "184"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"; "$CMDECHO" ""
			;;

			3) # suppression utilisateur
				"$CMDECHO" ""; set "214"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				"$CMDECHO" ""; set "282" "284"; FONCTXT "$1" "$2"; "$CMDECHO" -n -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CGREEN}$TXT2 ${CEND}"
				read -r SUPPR

				if FONCNO "$SUPPR"; then
					"$CMDECHO"
				else
					set "286"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""

					# variable utilisateur majuscule
					USERMAJ=$("$CMDECHO" "$USER" | "$CMDTR" "[:lower:]" "[:upper:]")

					# stop utilisateur
					FONCSERVICE stop "$USER"-rtorrent

                    # stop irssi retro-compatible
					if [ -f "/etc/init.d/"$USER"-irssi" ]; then
						FONCSERVICE stop "$USER"-irssi
					fi

					# arrêt user
					"$CMDPKILL" -u "$USER"

					# suppression script irssi retro-compatible
					if [ -f "/etc/init.d/"$USER"-irssi" ]; then
						"$CMDRM" /etc/init.d/"$USER"-irssi
						"$CMDUPDATERC" "$USER"-irssi remove
					fi

					"$CMDRM" /etc/init.d/"$USER"-rtorrent
					"$CMDUPDATERC" "$USER"-rtorrent remove

					# suppression configuration rutorrent
					"$CMDRM" -R "${RUCONFUSER:?}"/"$USER"
					"$CMDRM" -R "${RUTORRENT:?}"/share/users/"$USER"

					# suppression mot de passe
					"$CMDSED" -i "/^$USER/d" "$NGINXPASS"/rutorrent_passwd
					"$CMDRM" "$NGINXPASS"/rutorrent_passwd_"$USER"

					# suppression nginx
					"$CMDSED" -i '/location \/'"$USERMAJ"'/,/}/d' "$NGINXENABLE"/rutorrent.conf
					FONCSERVICE restart nginx

					# suppression backup .session
					"$CMDSED" -i "/FONCBACKUP $USER/d" "$SCRIPT"/backup-session.sh

					# suppression utilisateur
					"$CMDDELUSER" "$USER" --remove-home
					cd "$BONOBOX"
					"$CMDECHO" ""; set "264" "288"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				fi
			;;

			4) # debug
				"$CMDCHMOD" a+x "$FILES"/scripts/check-rtorrent.sh
				"$CMDBASH" "$FILES"/scripts/check-rtorrent.sh
			;;

			5) # sortir gestion utilisateurs
				"$CMDECHO" ""; set "290"; FONCTXT "$1"; "$CMDECHO" -n -e "${CGREEN}$TXT1 ${CEND}"
				read -r REBOOT

				if FONCNO "$REBOOT"; then
					FONCSERVICE restart nginx &> /dev/null
					"$CMDECHO" ""; set "200"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
					"$CMDECHO" ""; set "210"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"
					"$CMDECHO" -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; "$CMDECHO" ""
					exit 1
				fi

				if FONCYES "$REBOOT"; then
					"$CMDECHO" ""; set "210"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"
					"$CMDECHO" -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; "$CMDECHO" ""
					"$CMDSYSTEMCTL" reboot
				fi
				break
			;;

			*) # fail
				set "292"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
			;;
		esac
	done
fi
