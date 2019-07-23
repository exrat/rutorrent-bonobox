#!/bin/bash
#
# mise à jour mensuel db geoip2

CMDGEOIP2=$(/usr/bin/lsb_release -cs)

if [[ "$CMDGEOIP2" == buster ]]; then
	CMDWGET="/usr/bin/wget"
	CMDTAR="/usr/bin/tar"
	CMDRM="/usr/bin/rm"
	CMDMV="/usr/bin/mv"
	CMDCHOWN="/usr/bin/chown"

elif [[ "$CMDGEOIP2" == stretch ]]; then
	CMDWGET="/usr/bin/wget"
	CMDTAR="/bin/tar"
	CMDRM="/bin/rm"
	CMDMV="/bin/mv"
	CMDCHOWN="/bin/chown"
fi

cd /var/www/rutorrent/plugins/geoip2/database/
"$CMDWGET" https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
"$CMDTAR" xzfv GeoLite2-City.tar.gz
"$CMDRM" GeoLite2-City.mmdb
cd /var/www/rutorrent/plugins/geoip2/database/GeoLite2-City_*
"$CMDMV" GeoLite2-City.mmdb /var/www/rutorrent/plugins/geoip2/database/GeoLite2-City.mmdb
cd ..
"$CMDRM" -R GeoLite2-City.tar.gz GeoLite2-City_*
"$CMDCHOWN" www-data:www-data /var/www/rutorrent/plugins/geoip2/database/GeoLite2-City.mmdb
