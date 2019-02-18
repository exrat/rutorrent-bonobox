#!/bin/bash

################################################
# lancement gestion des utilisateurs ruTorrent #
################################################


# contrôle installation
if [ ! -f "$RUTORRENT"/histo-2019.log ]; then
	echo ""; set "220"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
	set "222"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"; echo ""
	exit 1
fi

# message d'accueil
clear
echo ""; set "224"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""
# shellcheck source=/dev/null
. "$INCLUDES"/logo.sh

# mise en garde
echo ""; set "226"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
set "228"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
set "230"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
echo ""; set "232"; FONCTXT "$1"; echo -n -e "${CGREEN}$TXT1 ${CEND}"
read -r VALIDE

if FONCNO "$VALIDE"; then
	echo ""; set "210"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"
	echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; echo ""
	exit 1
fi

if FONCYES "$VALIDE"; then
	# boucle ajout/suppression utilisateur
	while :; do
		# menu gestion multi-utilisateurs
		echo ""; set "234"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"
		set "236" "248"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "238" "254"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "240" "256"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "242" "296"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "244" "258"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "260"; FONCTXT "$1"; echo -n -e "${CBLUE}$TXT1 ${CEND}"
		read -r OPTION

		case $OPTION in
			1) # ajout utilisateur
				FONCUSER # demande nom user
				echo ""
				FONCPASS # demande mot de passe

				# récupération 5% root sur /home/user si présent
				FONCFSUSER "$USER"

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# ajout utilisateur
				useradd -M -s /bin/bash "$USER"

				# création mot de passe utilisateur
				echo "${USER}:${USERPWD}" | chpasswd

				# anti-bug /home/user déjà existant
				mkdir -p /home/"$USER"
				chown -R "$USER":"$USER" /home/"$USER"

				# variable utilisateur majuscule
				USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

				# récupération ip serveur
				FONCIP

				su "$USER" -c 'mkdir -p ~/watch ~/torrents ~/.session ~/.backup-session'

				# calcul port
				FONCPORT

				# configuration .rtorrent.rc
				FONCTORRENTRC "$USER" "$PORT" "$RUTORRENT"

				# configuration user rutorrent.conf
				sed -i '$d' "$NGINXENABLE"/rutorrent.conf
				FONCRTCONF "$USERMAJ"  "$PORT" "$USER"

				# configuration script backup .session (rétro-compatibilité)
				if [ -f "$SCRIPT"/backup-session.sh ]; then
					FONCBAKSESSION
				fi

				# config.php
				mkdir "$RUCONFUSER"/"$USER"
				FONCPHPCONF "$USER" "$PORT" "$USERMAJ"

				# plugins.ini
				cp -f "$FILES"/rutorrent/plugins.ini "$RUCONFUSER"/"$USER"/plugins.ini

				# configuration autodl-irssi
				if [ -f "/etc/irssi.conf" ]; then
					FONCIRSSI "$USER" "$PORT" "$USERPWD"
				fi

				# chroot user supplémentaire
				cat <<- EOF >> /etc/ssh/sshd_config
					Match User $USER
					ChrootDirectory /home/$USER
				EOF

				FONCSERVICE restart ssh

				# permissions
				chown -R "$WDATA" "$RUTORRENT"
				chown -R "$USER":"$USER" /home/"$USER"
				chown root:"$USER" /home/"$USER"
				chmod 755 /home/"$USER"

				# script rtorrent
				FONCSCRIPTRT "$USER"

				# htpasswd
				FONCHTPASSWD "$USER"

				# lancement user
				FONCSERVICE start "$USER"-rtorrent
				if [ -f "/etc/irssi.conf" ]; then
					FONCSERVICE start "$USER"-irssi
				fi

				# log users
				echo "userlog">> "$RUTORRENT"/histo-2019.log
				sed -i "s/userlog/$USER:$PORT/g;" "$RUTORRENT"/histo-2019.log
				FONCSERVICE restart nginx
				echo ""; set "218"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""
				set "182"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"
				set "184"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"; echo ""
			;;



			2) # modification mot de passe utilisateur
				echo ""; set "214"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				echo ""; FONCPASS

				echo ""; set "276"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# modification du mot de passe
				echo "${USER}:${USERPWD}" | chpasswd

				# htpasswd
				FONCHTPASSWD "$USER"

				echo ""; set "278" "280"; FONCTXT "$1" "$2"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				echo
				set "182"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"
				set "184"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"; echo ""
			;;

			3) # suppression utilisateur
				echo ""; set "214"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				echo ""; set "282" "284"; FONCTXT "$1" "$2"; echo -n -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CGREEN}$TXT2 ${CEND}"
				read -r SUPPR

				if FONCNO "$SUPPR"; then
					echo
				else
					set "286"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""

					# variable utilisateur majuscule
					USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

					# stop utilisateur
					FONCSERVICE stop "$USER"-rtorrent
					if [ -f "/etc/irssi.conf" ]; then
						FONCSERVICE stop "$USER"-irssi
					fi
					killall --user "$USER" rtorrent
					killall --user "$USER" screen

					# suppression script
					if [ -f "/etc/irssi.conf" ]; then
						rm /etc/init.d/"$USER"-irssi
						update-rc.d "$USER"-irssi remove
					fi
					rm /etc/init.d/"$USER"-rtorrent
					update-rc.d "$USER"-rtorrent remove

					# suppression configuration rutorrent
					rm -R "${RUCONFUSER:?}"/"$USER"
					rm -R "${RUTORRENT:?}"/share/users/"$USER"

					# suppression mot de passe
					sed -i "/^$USER/d" "$NGINXPASS"/rutorrent_passwd
					rm "$NGINXPASS"/rutorrent_passwd_"$USER"

					# suppression nginx
					sed -i '/location \/'"$USERMAJ"'/,/}/d' "$NGINXENABLE"/rutorrent.conf
					FONCSERVICE restart nginx

					# suppression backup .session
					sed -i "/FONCBACKUP $USER/d" "$SCRIPT"/backup-session.sh

					# suppression utilisateur
					deluser "$USER" --remove-home

					echo ""; set "264" "288"; FONCTXT "$1" "$2"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				fi
			;;

			4) # debug
				chmod a+x "$FILES"/scripts/check-rtorrent.sh
				bash "$FILES"/scripts/check-rtorrent.sh
			;;

			5) # sortir gestion utilisateurs
				echo ""; set "290"; FONCTXT "$1"; echo -n -e "${CGREEN}$TXT1 ${CEND}"
				read -r REBOOT

				if FONCNO "$REBOOT"; then
					FONCSERVICE restart nginx &> /dev/null
					echo ""; set "200"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
					echo ""; set "210"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"
					echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; echo ""
					exit 1
				fi

				if FONCYES "$REBOOT"; then
					echo ""; set "210"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"
					echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; echo ""
					reboot
				fi
				break
			;;

			*) # fail
				set "292"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
			;;
		esac
	done
fi
