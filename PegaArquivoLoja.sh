#!/bin/bash

echo "Digite a senha:"
read -s SENHA

SRC=$1 # Endereço absoluto do arquivo de origem
LISTA=$2 # Lista de lojas
LOJAS=($(cat ${LISTA})) ## Array com a lista total de lojas
SEM_SMA=($(cat ../Listas/Lojas_sem_SMA)) # Array com as lojas sem usuário SMA

for LJ in ${LOJAS[@]}; do
	LOG=../Logs/$4.${LJ}.log
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

	${SSH} ${IP} "sudo rsync -vgopz --progress --rsh='sshpass -p r0ux1n0l ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l sma' lxlasa11:${SRC} ${DTN}" >>${LOG} 2>&1 &
done	