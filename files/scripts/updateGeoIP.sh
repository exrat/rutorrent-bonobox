#!/bin/bash
#
# mise à jour mensuel db geoip et complément plugin city
cd /tmp
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
/bin/gunzip GeoIP.dat.gz GeoIPv6.dat.gz GeoLiteCity.dat.gz
cp -f GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
cp -f GeoLiteCity.dat /usr/share/GeoIP/GeoLiteCity.dat
cp -f GeoIP.dat /usr/share/GeoIP/GeoIP.dat
cp -f GeoIPv6.dat /usr/share/GeoIP/GeoIPv6.dat
rm GeoIP.dat GeoIPv6.dat GeoLiteCity.dat
