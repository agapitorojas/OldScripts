#!/bin/bash
<<INTRO
	Script para localizar, compactar e transmitir arquivos com informações de PDV.
	
	Local: /lasa/pdvs/dados
	Nome: infoLLLL.PPP
 
	Onde:
	LLLL = nº loja
	PPP = nº pdv
INTRO

DATA=$(date +%Y%m%d)
DIR="/lasa/pdvs/dados"
LOJA=$(hostname |cut -c6-)
[ ${LOJA} -lt 1000 ] && LOJA="0${LOJA}"
RPAR="-vogp --progress --remove-sent-files"
SPAR="-q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
SLEEP=$((RANDON % 61))

cd ${DIR}
find . -maxdepth 1 -type f -name 'info[0-9][0-9][0-9][0-9].[0-9][0-9][0-9]' |xargs -I '{}' zip /tmp/info${LOJA}_${DATA}.zip '{}'
sleep ${SLEEP}
su rsync -c "rsync ${RPAR} --rsh='ssh ${SPAR}' /tmp/info${LOJA}_${DATA}.zip lxlasa11:/LOCAL_STARX"
if [ $? -eq 0 ]; then
	echo "Arquivo info${LOJA}_${DATA}.zip enviado com sucesso."
else
	echo "Erro no envio."
fi