# Script d'installation ruTorrent / Nginx

* Multi-utilisateurs & Multilingue automatique en fonction de l'installation du serveur.
* Français, English, German
* Nécessite Debian 7 ou 8 (32/64 bits) & un serveur fraîchement installé

* Inclus VsFTPd (ftp & ftps sur le port 21), Fail2ban (avec conf nginx, ftp & ssh) & Proxy php
* Seedbox-Manager, Auteurs: Magicalex, Hydrog3n et Backtoback

Tiré du tutoriel de Magicalex pour mondedie.fr disponible ici:

[Installer ruTorrent sur Debian {nginx & php-fpm}](http://mondedie.fr/viewtopic.php?id=5302)

[Aide, support & plus si affinités à la même adresse !](http://mondedie.fr/)

**Auteur :** Ex_Rat

Merci Aliochka & Meister pour les conf de munin et VsFTPd

à Albaret pour le coup de main sur la gestion d'users et

Jedediah pour avoir joué avec le html/css du thème.

Aux traducteurs: Sophie, Spectre, Hardware et l'A... Gang.

## Installation:
Multilingue automatique
```
apt-get update && apt-get upgrade -y
apt-get install git-core -y

cd /tmp
git clone https://github.com/exrat/rutorrent-bonobox
cd rutorrent-bonobox
chmod a+x bonobox.sh && ./bonobox.sh
```

**Vous pouvez aussi forcer la langue de votre choix:**
```
# Français
chmod a+x bonobox.sh && ./bonobox.sh --fr

# English
chmod a+x bonobox.sh && ./bonobox.sh --en

# German
chmod a+x bonobox.sh && ./bonobox.sh --de
```

Pour gérer vos utilisateurs ultérieurement, il vous suffit de relancer le script

