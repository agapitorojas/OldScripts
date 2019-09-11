#!/bin/bash
<<DESCRICAO
	Script de execução remota de scripts Bourne Shell (sh) em sevidores ESXi.
	
	Autor: Agápito Rojas (agapito.junior@lasa.com.br)
	Versão 1.0 (05/04/2017)

	Utilização:
	# ./execshremoto.sh [SCRIPT] [LISTA DE HOSTS] [NOME DO LOG]

DESCRICAO

echo "Digite a senha:"
read -s SENHA

SHELL=$1 # Script a ser executado
LISTA=$2 # Lista de hosts (nº da loja)
SAIDA=$3 # Nome da saída do log
LOJAS=($(cat ${LISTA})) # Array com a lista total de lojas
DIRLOG="/home/wefix007/Logs" # Diretório de logs
USER="root"
export SSHPASS=${SENHA}
SSH="sshpass -e ssh -l ${USER} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR"

for LJ in ${LOJAS[@]}; do
	LOG=${DIRLOG}/${SAIDA}.${LJ}.log
	IP=$(ver_end ${LJ} |grep Loja |cut -f1 |sed 's/.1$/.2/g')
	echo "LOJA ${LJ}"
	echo "LOJA ${LJ}" >>${LOG}

	${SSH} ${IP} "sh -s" < ${SHELL} >>${LOG} 2>&1 &
done