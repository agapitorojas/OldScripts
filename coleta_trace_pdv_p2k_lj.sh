#!/bin/bash
: '
	Script de coleta de traces de PDVs P2K.

	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
	Revisor: Ricardo Gomes (ricardo.gomes@lasa.com.br)
	Versão: 1.1 - 15/07/2016

	Script alterado para execução no servidor de loja.
'
LOJA=$(hostname |cut -c6-)
[ ${LOJA} -lt 1000 ] && LOJA="0${LOJA}"
FILE=$(basename $0) ## Nome do script
LOG=/DSOP/DLOG/${FILE%.*}.log ## Arquivo de log
DIRDTN="/lasa/LOG_PDV_P2K" ## Diretório de destino
LISTA="/DSOP/DTAB/PDVs_P2K" ## Lista no formato LLLL;A.B.C.D;PDV
SSHOPT="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" ## Opções do SSH
export SSHPASS="123456" ## Senha do usuário root

for LINHA in $(grep ^${LOJA} ${LISTA}); do
	LJ=$(echo ${LINHA} |cut -d';' -f1)
	IP=$(echo ${LINHA} |cut -d';' -f2)
	PDV=$(echo ${LINHA} |cut -d';' -f3)
	LOGPDV="/DSOP/DLOG/PDV${PDV}.log"
	echo "LJ${LJ} PDV${PDV}" |tee -a ${LOGPDV}
	[ ! -d ${DIRDTN}/${LJ}/${PDV} ] && mkdir -p ${DIRDTN}/${LJ}/${PDV}
	sshpass -e scp ${SSHOPT} root@${IP}:/p2k/bin/CSIDebugFile.txt ${DIRDTN}/${LJ}/${PDV} >>${LOGPDV} 2>&1 && sleep 5 && echo "CSIDebugFile.txt copiado." >>${LOGPDV} &
	sshpass -e scp -r ${SSHOPT} root@${IP}:/p2k/bin/debug_P2K ${DIRDTN}/${LJ}/${PDV} >>${LOGPDV} 2>&1 && sleep 5 && echo "FIM!" >>${LOGPDV} &
	SAIDA=$?
	if [ ${SAIDA} -eq 0 ]; then
		echo "Arquivos do PDV ${PDV} da Loja ${LJ} enviados com sucesso." >>${LOG}
	else
		echo "Erro ${SAIDA} no PDV ${PDV} da Loja ${LJ}." >>${LOG}
	fi
done