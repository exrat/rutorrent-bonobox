#!/bin/bash
#
if [ -e /var/log/nginx/rutorrent-access.log.1 ]; then
	# Récupération des logs (J et J-1) et fusion
	cp /var/log/nginx/rutorrent-access.log /tmp/access.log.0
	cp /var/log/nginx/rutorrent-access.log.1 /tmp/access.log.1
	cd /tmp
	cat access.log.1 access.log.0 > access.log
else
	cd /tmp
	cp /var/log/nginx/rutorrent-access.log /tmp/access.log
fi

sed -i '/plugins/d' access.log
sed -i '/getsettings.php/d' access.log
sed -i '/setsettings.php/d' access.log
sed -i '/@USERMAJ@\ HTTP/d' access.log
ccze -h < /tmp/access.log > @RUTORRENT@/logserver/access.html
