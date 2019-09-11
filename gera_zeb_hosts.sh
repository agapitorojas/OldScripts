#!/bin/bash

ANTIG=($(cat /DSOP/DTAB/lojas_rede_antiga |sort -n |uniq |cut -d: -f1 |sed 's/^/0/g'))
LISTA="$1"
LOJAS=($(cat ${LISTA}))

for LJ in ${LOJAS[@]}; do
	if [[ "${ANTIG[*]}" =~ "${LJ}" ]]; then
		OCT4_ZEB1="101"
		OCT4_ZEB2="102"
	else
		OCT4_ZEB1="19"
		OCT4_ZEB2="20"
	fi
	PREF=$(/DSOP/DEXE/ver_end ${LJ} |cut -f1 |cut -d. -f1-3)
	IP_ZEB1="${PREF}.${OCT4_ZEB1}"
	IP_ZEB2="${PREF}.${OCT4_ZEB2}"
	echo -e "${IP_ZEB1}\tzeb1_${LJ}"
	echo -e "${IP_ZEB2}\tzeb2_${LJ}"
done