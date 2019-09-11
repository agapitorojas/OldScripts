#!/bin/bash

echo "Digite a senha:"
read -s SENHA

SHELL=$1 # Script a ser executado
LISTA=$2 # Lista de lojas
SAIDA=$3 # Nome da saída do log
LOJAS=($(cat ${LISTA})) # Array com a lista total de lojas
SEM_SMA=($(cat ../Listas/Lojas_sem_SMA)) # Array com as lojas sem usuário SMA

for LJ in ${LOJAS[@]}; do
	LOG=../Logs/${SAIDA}.${LJ}.log
	if [[ "${SEM_SMA[*]}" =~ "${LJ}" ]]; then
		USER="arojas"
		export SSHPASS=${SENHA}
	else
		USER="sma"
		export SSHPASS="r0ux1n0l"
	fi
	SSH="sshpass -e ssh -l ${USER} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR"
	IP=$(ver_end ${LJ} |grep Loja |cut -f1)
	echo "LOJA ${LJ}"
	echo "LOJA ${LJ}" >>${LOG}

	${SSH} ${IP} "sudo bash -s" < ${SHELL} >>${LOG} 2>&1 &
done