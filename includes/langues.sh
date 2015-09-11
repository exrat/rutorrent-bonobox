#!/bin/bash

# langues
OPTS=$(getopt -o vhns: --long en,fr,it,de,es,ru,sr: -n 'parse-options' -- "$@")
eval set -- "$OPTS"
while true; do
  case "$1" in
	--en) GENLANG="en" ; break ;;
	--fr) GENLANG="fr" ; break ;;
	--de) GENLANG="de" ; break ;;
	--ru) GENLANG="ru" ; break ;;
	--es) GENLANG="en" ; break ;;
	--ar) GENLANG="en" ; break ;;
	--it) GENLANG="en" ; break ;;
	--sr) GENLANG="en" ; break ;;
	*|\?)
		BASELANG="${LANG:0:2}"
		# detection auto
		if   [ "$BASELANG" = "en" ]; then GENLANG="en"
		elif [ "$BASELANG" = "fr" ]; then GENLANG="fr"
		elif [ "$BASELANG" = "de" ]; then GENLANG="de"
		elif [ "$BASELANG" = "ru" ]; then GENLANG="ru"
		elif [ "$BASELANG" = "es" ]; then GENLANG="en"
		elif [ "$BASELANG" = "ar" ]; then GENLANG="en"
		elif [ "$BASELANG" = "it" ]; then GENLANG="en"
		elif [ "$BASELANG" = "sr" ]; then GENLANG="en"
		else
			GENLANG="en" ; fi ; break ;;
	esac
done
