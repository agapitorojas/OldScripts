#!/bin/bash

CMD=$1 # Comando a ser executado
LISTA=$2 # Endereço absoluto do destino
SAIDA=$3 # Nome da saída do log
SERVERS=($(cat ${LISTA})) # Array com a lista total de servidores

for SRV in ${SERVERS[@]}; do
	LOG=../Logs/${SAIDA}.${SRV}.log
	SSH="ssh -o ConnectTimeout=15 -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o LogLevel=ERROR"
	IP=$(/usr/bin/resolveip ${SRV} |awk '{print $NF}')
	echo "${SRV}" |tee -a ${LOG}
	${SSH} ${IP} "${CMD}" >>${LOG} 2>&1 &
done