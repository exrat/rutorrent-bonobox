#!/bin/bash
#
# mise à jour mensuel db geoip2
cd /var/www/rutorrent/plugins/geoip2/database/
/usr/bin/wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
tar xzfv GeoLite2-City.tar.gz
rm GeoLite2-City.mmdb
cd /var/www/rutorrent/plugins/geoip2/database/GeoLite2-City_*
mv GeoLite2-City.mmdb /var/www/rutorrent/plugins/geoip2/database/GeoLite2-City.mmdb
cd ..
rm -R GeoLite2-City.tar.gz GeoLite2-City_*
chown www-data:www-data /var/www/rutorrent/plugins/geoip2/database/GeoLite2-City.mmdb
