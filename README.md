# Script d'installation ruTorrent / Nginx

* Nécessite Debian 7 ou 8 (32/64 bits) & un serveur fraîchement installé
* Multi-utilisateurs

* Inclus VsFTPd (ftp & ftps sur le port 21), Fail2ban (avec conf nginx, ftp & ssh) & Proxy php
* Seedbox-Manager, Auteurs: Magicalex, Hydrog3n et Backtoback

Tiré du tutoriel de Magicalex pour mondedie.fr disponible ici:

[Installer ruTorrent sur Debian {nginx & php-fpm}](http://mondedie.fr/viewtopic.php?id=5302)

[Aide, support & plus si affinités à la même adresse !](http://mondedie.fr/)

**Auteur :** Ex_Rat

Merci Aliochka & Meister pour les conf de munin et VsFTPd

à Albaret pour le coup de main sur la gestion d'users et

Jedediah pour avoir joué avec le html/css du thème

## Installation:
```
apt-get update && apt-get upgrade -y
apt-get install git-core -y

cd /tmp
git clone https://github.com/exrat/rutorrent-bonobox
cd rutorrent-bonobox
chmod a+x bonobox.sh && ./bonobox.sh
```

Pour gérer vos utilisateurs ultérieurement, il vous suffit de relancer le script

#### Inspiration:
- [hexodark](https://github.com/gaaara/)
