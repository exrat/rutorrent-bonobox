#!/bin/bash
#
# Auteur : Magicalex
# Version : 1.2
# script de backup des données rtorrent adapté pour le script auto.


#nombre de sauvegarde souhaité 7 par defaut
NBSAVE=7

#Définition des chemins absolues des commandes pour la crontab et de la date
CMDBACKUP=$(/usr/bin/lsb_release -cs)

if [[ "$CMDBACKUP" == buster ]]; then
    CMDDATE="/usr/bin/date"
    CMDMKDIR="/usr/bin/mkdir"
    CMDCHOWN="/usr/bin/chown"
    CMDCP="/usr/bin/cp"
    CMDGREP="/usr/bin/grep"
    CMDLS="/usr/bin/ls"
    CMDWC="/usr/bin/wc"
    CMDZIP="/usr/bin/zip"
    CMDRM="/usr/bin/rm"
    CMDTAIL="/usr/bin/tail"
    DATE=$("$CMDDATE" '+%d-%m-%y-a-%Hh%Mm%Ss')

elif [[ "$CMDBACKUP" == stretch ]]; then
    CMDDATE="/bin/date"
    CMDMKDIR="/bin/mkdir"
    CMDCHOWN="/bin/chown"
    CMDCP="/bin/cp"
    CMDGREP="/bin/grep"
    CMDLS="/bin/ls"
    CMDWC="/usr/bin/wc"
    CMDZIP="/usr/bin/zip"
    CMDRM="/bin/rm"
    CMDTAIL="/usr/bin/tail"
    DATE=$("$CMDDATE" '+%d-%m-%y-a-%Hh%Mm%Ss')
fi

# fonction backup : exige un paramètre -> nom du user
FONCBACKUP () {
    if [ ! "$1" ]; then
        exit 1
    fi

    REPERTOIREUSER=/home/"$1"/.backup-session

    if [ ! -d "$REPERTOIREUSER" ]; then
        "$CMDMKDIR" /home/"$1"/.backup-session
        "$CMDCHOWN" -R "$1":"$1" /home/"$1"/.backup-session
    fi

    "$CMDMKDIR" /home/"$1"/.backup-session/Sauvegarde-du-"$DATE"
    "$CMDCP" /home/"$1"/.session/*.torrent /home/"$1"/.session/*.rtorrent /home/"$1"/.session/*.libtorrent_resume /home/"$1"/.backup-session/Sauvegarde-du-*
    cd /home/"$1"/.backup-session || exit
    "$CMDZIP" -qr sauvegarde-du-"$("$CMDDATE" '+%d-%m-%y-a-%Hh%Mm%Ss')".zip Sauvegarde-du-*
    "$CMDRM" -Rf /home/"$1"/.backup-session/Sauvegarde-du-*
    "$CMDCHOWN" -R "$1":"$1" /home/"$1"/.backup-session
    COMPTAGE=$("$CMDLS" | "$CMDGREP" sauvegarde | "$CMDWC" -l)

    if [ "$COMPTAGE" -gt "$NBSAVE" ]; then
        "$CMDRM" -Rf "$("$CMDLS" -at /home/"$1"/.backup-session/ | "$CMDGREP" sauvegarde | "$CMDTAIL" -1)"
    fi
}
# liste users
exit 0
