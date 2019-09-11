#!/bin/bash

ANTIG=($(cat /DSOP/DTAB/lojas_rede_antiga |sort -n |uniq |cut -d: -f1 |sed 's/^/0/g'))
LISTA="$1"
LOJAS=($(cat ${LISTA}))

for LJ in ${LOJAS[@]}; do
	if [[ "${ANTIG[*]}" =~ "${LJ}" ]]; then
		echo "Loja ${LJ} é padrão antigo"
	else
		echo "Loja ${LJ} é padrão novo"
	fi
done