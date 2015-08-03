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
