#!/bin/bash
: '
	Script de coleta de traces de PDVs P2K.

	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
	Revisor: Ricardo Gomes (ricardo.gomes@lasa.com.br)
	Versão: 1.0 - 15/07/2016
'

FILE=$(basename $0) ## Nome do script
LOG=/DSOP/DLOG/${FILE%.*}.log ## Arquivo de log
DIRDTN="/lasa/LOG_PDV_P2K" ## Diretório de destino
LISTA="$1" ## Lista no formato LLLL;A.B.C.D;PDV
SSHOPT="-q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ## Opções do SSH
export SSHPASS="123456" ## Senha do usuário root

for LINHA in $(cat $1); do
	LJ=$(echo ${LINHA} |cut -d';' -f1)
	IP=$(echo ${LINHA} |cut -d';' -f2)
	PDV=$(echo ${LINHA} |cut -d';' -f3)
	echo "LJ${LJ} PDV${PDV}" |tee -a ${LOG}
	[ ! -d ${DIRDTN}/${LJ}/${PDV} ] && mkdir -p ${DIRDTN}/${LJ}/${PDV}
	sshpass -e scp ${SSHOPT} root@${IP}:/p2k/bin/CSIDebugFile.txt ${DIRDTN}/${LJ}/${PDV} >>${LOG} 2>&1
	sshpass -e scp -r ${SSHOPT} root@${IP}:/p2k/bin/debug_P2K ${DIRDTN}/${LJ}/${PDV} >>${LOG} 2>&1
	SAIDA=$?
	if [ ${SAIDA} -eq 0 ]; then
		echo "Arquivos do PDV ${PDV} da Loja ${LJ} enviados com sucesso." >>${LOG}
	else
		echo "Erro ${SAIDA} no PDV ${PDV} da Loja ${LJ}." >>${LOG}
	fi
done