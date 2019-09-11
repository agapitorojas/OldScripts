#/bin/bash

BASE=$(basename $0) ## Nome do script
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Arquivos de log
PIDFILE="/DSOP/DLOG/${BASE%%.*}.pid" ## Arquivo de PID
SRCDIR="/smb/EXPORTS_SAFE_HML" ## Diretório de origem
DTNDIR="/LOCAL_STATX/BILHETES_SEGURO" ## Diretório de destino

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

verifica_pid

if [ -d ${SRCDIR} ]; then
	LASTGEC=$(ls ${SRCDIR}/GEC*.cup 2>/dev/null |tail -1)
	LASTGEO=$(ls ${SRCDIR}/GEO*.cup 2>/dev/null |tail -1)
	LASTRFC=$(ls ${SRCDIR}/RFC*.cup 2>/dev/null |tail -1)
	LASTRFO=$(ls ${SRCDIR}/RFO*.cup 2>/dev/null |tail -1)
	[ ! -f ${LASTGEC} ] && echo "Arquivo GEC não encontrado $(date '+%F - %T')" >>${LOG} 2>&1
	[ ! -f ${LASTGEO} ] && echo "Arquivo GEO não encontrado $(date '+%F - %T')" >>${LOG} 2>&1
	[ ! -f ${LASTRFC} ] && echo "Arquivo RFC não encontrado $(date '+%F - %T')" >>${LOG} 2>&1
	[ ! -f ${LASTRFO} ] && echo "Arquivo RFO não encontrado $(date '+%F - %T')" >>${LOG} 2>&1
	CUPARR=(${LASTGEC} ${LASTGEO} ${LASTRFC} ${LASTRFO})
	if [ ${#CUPARR[*]} -eq 4 ]; then
		NEWHASH=$(md5sum ${CUPARR[*]} |awk '{print $1}' |md5sum |awk '{print $1}')
		mkdir -p ${DTNDIR}
		LASTHASH=$(cat ${DTNDIR}/hash.md5 2>/dev/null)
		if [ ${NEWHASH} = ${LASTHASH} ]; then
			echo "Sem alteracao nos arquivos $(date '+%F - %T')" >>${LOG} 2>&1
		else
			echo -e "Início $(date '+%F - %T')\n" >>${LOG} 2>&1
			if [ $(ls ${DTNDIR}/*.cup 2>/dev/null |wc -l) -gt 0 ]; then
				echo "Removendo arquivos antigos:" >>${LOG} 2>&1
				rm -fv ${DTNDIR}/*.cup >>${LOG} 2>&1
				echo "" >>${LOG} 2>&1
			fi
			echo "Copiando arquivos novos:" >>${LOG} 2>&1
			cp -v ${CUPARR[*]} ${DTNDIR} >>${LOG} 2>&1
			echo "Renomeando arquivos novos:" >>${LOG} 2>&1
			for CUPFULL in $(ls ${DTNDIR}/*.cup); do
				CUP=$(basename ${CUPFULL})
				mv -v ${DTNDIR}/${CUP} ${DTNDIR}/${CUP,,} >>${LOG} 2>&1
			done
			echo "Hash $(echo ${NEWHASH} |tee ${DTNDIR}/hash.md5)" >>${LOG} 2>&1
			echo -e "\nFim $(date '+%F - %T')\n" >>${LOG} 2>&1
		fi
	else
		echo "Sem a quantidade mínima de arquivos $(date '+%F - %T')" >>${LOG} 2>&1
	fi
else
	echo "Erro ao acessar ${SRCDIR} $(date '+%F - %T')" >>${LOG} 2>&1
fi

rm -f ${PIDFILE}
## Fim do script