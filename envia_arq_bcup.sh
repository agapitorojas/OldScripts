#!/usr/bin/env bash
<<HEAD
    SCRIPT: envia_arq_bcup.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para transmitir arquivos de cupom para o ibmfarm01
    VERSION: 1.0 (26/08/2019)
    HISTORY:
HEAD

base="$(basename $0)"
destino="ibmfarm01"
dir_loja="/lasa/usr/COMNC/STATX/BACKUP_CUP"
dir_dtn="/lasa/usr/COMNC/STARX/ARQ_CUP"
log="/DSOP/DLOG/${base%%.*}.log"
pid="/DSOP/DLOG/${base%%.*}.pid"
usuario="TESDIGIT"

verifica_pid() {
	if [ -s ${pid} ]; then
		ultimo_pid=$(cat ${pid})
		if [ -d /proc/${ultimo_pid} ]; then
			echo "$(date '+%F %T') - Processo em execucao." >>${log} 2>&1
			exit 0
		else
			echo $$ >${pid}
		fi
	else
		echo $$ >${pid}
	fi
}

verifica_pid

echo "$(date '+%F %T') - Inicio." >>${log} 2>&1
rsync -acuv --timeout=60 ${dir_loja}/*.gz ${usuario}@${destino}:${dir_dtn} >>${log} 2>&1
echo "$(date '+%F %T') - Fim." >>${log} 2>&1

rm -f ${pid}