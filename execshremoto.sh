#!/bin/bash
###########
#
#	Script de execução remota de scripts
#
#	Modo de execução:
#	# ./execshremoto.sh [SCRIPT] [LISTA DE HOSTS] [NOME DO LOG]
#
DATA=`date +%Y%m%d`
LISTA=`cat $2`
NLOG=$3
SHELL=$1
SSH="sshpass -p r0ux1n0l ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR sma@"

for NLJ in ${LISTA}; do
	LOG=../Logs/${NLOG}.${NLJ}.txt
	NIP=`ver_end ${NLJ} | grep Loja | tr -s "\t" " " | cut -d" " -f1`

	echo "LOJA "${NLJ}
	echo "LOJA ${NLJ}" >>${LOG}
	
	${SSH}${NIP} "bash -s" < ${SHELL} >>${LOG} 2>&1 &

done
