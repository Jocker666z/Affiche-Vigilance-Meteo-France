#!/bin/bash
# Affiche les vigilances de meteo france par departement
#
# Author : Romain Barbarot
# https://github.com/Jocker666z/
#
# licence : GNU GPL-2.0
# Dependance: vigilancemeteo (MIT) https://github.com/oncleben31/vigilancemeteo


# Argument
if [[ "$1" =~ ^-?[0-9]+$ ]]; then
	DEPARTEMENT="$1"
else
	echo "Usage: vigilance-meteo.sh \"Numero du departement\""
	exit
fi

VigilanceImport() {
python3 << END
import vigilancemeteo
zone = vigilancemeteo.DepartmentWeatherAlert("$DEPARTEMENT")
print(zone.summary_message('text'))
END
}

Vigilance() {
mapfile -t RawVigilanceList < <(VigilanceImport | sed '1d')
NBV="${#RawVigilanceList[@]}"
if [ "$NBV" -gt "0" ]; then
	for i in "${RawVigilanceList[@]}"; do
		i=$(echo "$i" | sed 's/^...//')			# Remove 3 first characters of all lines
		if [[ $i == *"Jaune"* ]]; then
			i=$(echo "$i" | sed 's/^/🟨 /')		# Add color icon at start of line
		fi
		if [[ $i == *"Orange"* ]]; then
			i=$(echo "$i" | sed 's/^/🟧 /')
		fi
		if [[ $i == *"Rouge"* ]]; then
			i=$(echo "$i" | sed 's/^/🟥 /')
		fi
		i=$(echo "$i" | cut -f1 -d":")			# Remove all after ":"
		echo "$i"
	done
fi
}

Vigilance

exit
