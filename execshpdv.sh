#!/bin/bash
######################################################################
##
#	Script de execução remota de scripts
#
#	Modo de execução:
#	# ./execshpdv.sh [SCRIPT] [LISTA DE HOSTS] [NOME DO LOG]
#
#	Versão 1.0 - Adaptado do execshremoto.sh para execução em PDVs.
#
######################################################################

echo "Digite a senha do root."
read -s SSHPASS
export SSHPASS

DATA=$(date "+%F %T")
LISTA=$2
LOJA=$(hostname |cut -c6-)
[ "${LOJA}" -lt 1000 ] && LOJA=0${LOJA}
NLOG=$3
SHELL=$1
SSH="sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR root@"

for LINE in $(grep ${LOJA} ${LISTA}); do
	
	PDV=$(echo ${LINE} |cut -d';' -f3)
	IP=$(echo ${LINE} |cut -d';' -f4)
	LOG="/tmp/${NLOG}${PDV}.log"

	echo "PDV "${PDV}
	echo "PDV ${PDV}" >>${LOG}
	
	${SSH}${IP} "bash -s" < ${SHELL} >>${LOG} 2>&1 &

done