#!/bin/bash
#

LIBZEN0="0.4.33"
LIBMEDIAINFO0="0.7.86"
MEDIAINFO="0.7.86"

function FONCMEDIAINFO ()
{
wget http://mediaarea.net/download/binary/libzen0/"$LIBZEN0"/libzen0_"$LIBZEN0"-1_"$SYS"."$DEBNUMBER"
wget http://mediaarea.net/download/binary/libmediainfo0/"$LIBMEDIAINFO0"/libmediainfo0_"$LIBMEDIAINFO0"-1_"$SYS"."$DEBNUMBER"
wget http://mediaarea.net/download/binary/mediainfo/"$MEDIAINFO"/mediainfo_"$MEDIAINFO"-1_"$SYS"."$DEBNUMBER"

dpkg -i libzen0_"$LIBZEN0"-1_"$SYS"."$DEBNUMBER"
dpkg -i libmediainfo0_"$LIBMEDIAINFO0"-1_"$SYS"."$DEBNUMBER"
dpkg -i mediainfo_"$MEDIAINFO"-1_"$SYS"."$DEBNUMBER"
}

cd /tmp || exit

if [[ $(uname -m) == i686 ]]; then
	SYS="i386"
elif [[ $(uname -m) == x86_64 ]]; then
	SYS="amd64"
fi

if [[ $VERSION =~ 7. ]]; then
	apt-get install -y libtinyxml2-0.0.0 libglib2.0-0 libmms0
	FONCMEDIAINFO

elif [[ $VERSION =~ 8. ]]; then
	apt-get install -y libtinyxml2-2 libmms0
	FONCMEDIAINFO
fi

