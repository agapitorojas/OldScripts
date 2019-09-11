#!/bin/bash
:"
	Script de download dos arquivos de Regras de Descontos, Campanhas e Eventos nas lojas Prisma.

	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)

	Versão 1.0 (25/10/2016)
"
SCRIPT=$(basename $0)
HOST=$(hostname)
LOJA=$(hostname |cut -c6-)
[ ${LOJA} -lt 1000 ] && LOJA=0${LOJA}
STARX="/lasa/usr/COMNC/STARX"
SERVER=$(cat /DSOP/DTAB/servidor_arquivos_p2k)
SSH="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
RSYNC="rsync -vgop --progress --remove-source-files --bwlimit=64 --timeout=30 --rsh='${SSH}'"
TEMPO=$(echo "$RANDOM % 61" |bc)
PARAM="$1"
PROCESSO=$(echo "${PARAM}" |tr '[:lower:]' '[:upper:]')

if [ "$#" -ne 1 ]; then
	echo "Utilização: ${SCRIPT} {fidelizacao|campanhas|eventos|cuponagem}"
	exit 1
fi

timestamp(){
	date +%Y%m%d%H%M%S
}

data_hora(){
	date '+%F %T'
}

saida(){
	echo $?
}

