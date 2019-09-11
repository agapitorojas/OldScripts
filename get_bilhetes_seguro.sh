#/bin/bash

BASE=$(basename $0) ## Nome do script
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Arquivos de log
PIDFILE="/DSOP/DLOG/${BASE%%.*}.pid" ## Arquivo de PID
SRV="lxlasa11" ## Servidor de origem
SRCDIR="/LOCAL_STATX/BILHETES_SEGURO" ## Diretório de origem
DTNDIR="/lasa/pdvs/dados" ## Diretório de destino

function verifica_pid {
	if [ -s ${PIDFILE} ]; then
		LASTPID=$(cat ${PIDFILE})
		if [ -d /proc/${LASTPID} ]; then
			echo "Processo em execucao $(date '+%F - %T')" >>${LOG} 2>&1
			exit 0
		else
			echo $$ >${PIDFILE}
		fi
	else
		echo $$ >${PIDFILE}
	fi
}

function verifica_host {
	/usr/bin/host ${SRV} >/dev/null 2>&1
	if [ "$?" -eq "0" ]; then
		/usr/bin/nc -zw3 ${SRV} 22 >/dev/null 2>&1
		if [ "$?" -ne "0" ]; then
			echo "Erro no acesso SSH ao ${SRV} $(date '+%F - %T')" >>${LOG} 2>&1
			rm -f ${PIDFILE}
			exit 1
		fi
	else
		echo "Erro ao resolver o nome ${SRV} $(date '+%F - %T')" >>${LOG} 2>&1
		rm -f ${PIDFILE}
		exit 1
	fi
}

function espere {
	N=${1:-10} ## Se valor não atribuído, utilizar "10"
	sleep $(echo "${RANDOM} % ${N}" |bc)
}

verifica_pid
verifica_host

LOCALGEC=$(ls ${DTNDIR}/[gG][eE][cC]*.cup 2>/dev/null |tail -1)
LOCALGEO=$(ls ${DTNDIR}/[gG][eE][oO]*.cup 2>/dev/null |tail -1)
LOCALRFC=$(ls ${DTNDIR}/[rR][fF][cC]*.cup 2>/dev/null |tail -1)
LOCALRFO=$(ls ${DTNDIR}/[rR][fF][oO]*.cup 2>/dev/null |tail -1)
[ ! -f ${LOCALGEC} ] && echo "Arquivo GEC não encontrado $(date '+%F - %T')" >>${LOG} 2>&1
[ ! -f ${LOCALGEO} ] && echo "Arquivo GEO não encontrado $(date '+%F - %T')" >>${LOG} 2>&1
[ ! -f ${LOCALRFC} ] && echo "Arquivo RFC não encontrado $(date '+%F - %T')" >>${LOG} 2>&1
[ ! -f ${LOCALRFO} ] && echo "Arquivo RFO não encontrado $(date '+%F - %T')" >>${LOG} 2>&1
CUPARR=(${LOCALGEC} ${LOCALGEO} ${LOCALRFC} ${LOCALRFO})
if [ ${#CUPARR[*]} -gt 0 ]; then
	LOCALHASH=$(/usr/bin/md5sum ${CUPARR[*]} 2>/dev/null |awk '{print $1}' |/usr/bin/md5sum |awk '{print $1}')
else
	LOCALHASH=""
fi
espere 31
REMOTEHASH=$(ssh -o ConnectTimeout=15 ${SRV} "cat ${SRCDIR}/hash.md5")
if [ "${LOCALHASH}" != "${REMOTEHASH}" ]; then
	echo -e "Início $(date '+%F - %T')\n" >>${LOG} 2>&1
	espere 61
	rsync -gopvz ${SRV}:${SRCDIR}/*.cup ${DTNDIR} >>${LOG} 2>&1
	if [ "$?" -eq "0" ]; then
		echo -e "\nArquivos coletados com sucesso $(date '+%F - %T')" >>${LOG} 2>&1
	else
		echo -e "\nErro $? ao baixar os arquivos $(date '+%F - %T')" >>${LOG} 2>&1
	fi
	echo -e "Fim $(date '+%F - %T')\n" >>${LOG} 2>&1
else
	echo -e "Sem alteração nos arquivos $(date '+%F - %T')\n" >>${LOG} 2>&1
fi

rm -f ${PIDFILE}