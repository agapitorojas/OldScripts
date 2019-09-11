#!/bin/bash
DATA=$(date +%Y%m%d)
LOJA=$(hostname |cut -d_ -f2)
[ ${LOJA} -lt 1000 ] && LOJA=0${LOJA}
DIR_REMOTO="lxlasa11:/lasa/INSTALLP2K"
DIR_TELAS="/p2ksp/sp_lj${LOJA}/atualizacaoComponente"
PARAM_RSYNC="-av --progress"
PARAM_SSH="-q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
SLEEP=$(echo "${RANDOM} % 61" |bc)

if [ ! -f /DSOP/DTAB/EH_P2K_TOTAL -a ! -f /DSOP/DTAB/EH_P2K_HIBRIDA ]; then
	echo "Loja não é P2K."
	exit 0
fi

if [ -d ${DIR_TELAS} ]; then
	sleep ${SLEEP}
	echo "Baixando telas."
	su rsync -c "rsync ${PARAM_RSYNC} --rsh='ssh ${PARAM_SSH}' ${DIR_REMOTO}/telas.tbz2 /tmp"
	SAIDA=$?
	if [ ${SAIDA} -eq 0 ]; then
		cd ${DIR_TELAS}
		echo "Fazendo backup de telas atuais."
		tar cjvf telas_${DATA}.tbz2 telas
		SAIDA=$?
		if [ ${SAIDA} -eq 0 ]; then
			rm -fr telas
			echo "Descompactando telas novas."
			tar xjvf /tmp/telas.tbz2
			SAIDA=$?
			if [ ${SAIDA} -eq 0 ]; then
				chown -R p2ksp:p2ksp telas
				chmod -R 777 telas
				echo "Telas atualizadas com sucesso."
			else
				echo "Erro ao descompactar telas."
				exit 4
			fi
		else
			echo "Erro ao fazer backup das telas."
			exit 3
		fi
	else
		echo "Erro ao baixar arquivo de telas."
		exit 2
	fi
else
	echo "Diretório não encontrado."
	exit 1
fi