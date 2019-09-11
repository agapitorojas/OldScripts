#!/bin/bash
echo "Digite a senha:"
read -s SENHA
export SSHPASS=${SENHA}

CMDS=$1
DATA=$(date +%Y%m%d)
LISTA=$(cat $2)
NLOG=$3
SSH="sshpass -e ssh -l arojas -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR"

for NLJ in ${LISTA}; do
	LOG=../Logs/$3.${NLJ}.log
	NIP=$(ver_end ${NLJ} |grep Loja |cut -f1)

	echo "LOJA "${NLJ}
	echo "LOJA ${NLJ}" >>${LOG}
	${SSH} ${NIP} $1 >>${LOG} 2>&1 &
done
