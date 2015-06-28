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


## Developpement vagrant

Pour tester le script en local vous pouvez utiliser une machine virtuelle  
D'abord installer virtuelbox et vagrant  

 * https://www.virtualbox.org/
 * https://www.vagrantup.com/

mise en route :  

```bash
cd rutorrent-bonobox
# peut prendre du temps la première installation
vagrant up

# pour se connecter en ssh
vagrant ssh
cd bonobox
chmod +x bonobox.sh

# installe le script
./bonobox.sh
```

Vous pouvez associer un nom de domaine à votre machine virtuelle  
Pour cela il faut configurer le fichier hosts

macosx et linux :  

```bash
sudo echo "192.168.33.10 bonobox.dev" >> /etc/hosts
```

windows :  
http://www.commentcamarche.net/faq/5993-modifier-son-fichier-hosts
