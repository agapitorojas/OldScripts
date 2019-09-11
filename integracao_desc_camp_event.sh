#!/bin/bash
:"
  Novo script de integração de Regras de Descontos, Campanhas e Eventos com lojas Prisma.

  Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
  Versão: 1.0 - ??/09/2016
"
SCRIPT=$(basename $0)
LOG=/DSOP/DLOG/${SCRIPT%.*}.log
NFS_FILESERVER="/nfs/campanhas_eventos_lasafs01"
STATX="/lasa/usr/COMNC/STATX"
RSYNC="rsync -avz --progress --remove-source-files"

timestamp(){
	date +%Y%m%d%H%M%S
}

data_hora(){
	date '+%F %T'
}

saida(){
	echo $?
}

coleta_arquivos(){
	cd ${ORIGEM}
	if [ "$(saida)" -eq 0 ]; then ## Testa montagem automática do NFS.
		if [ "$(ls ${ARQUIVOS} |wc -l)" -ge "${MIN}" ]; then
			echo -e "$(data_hora) ${HOST} - Movendo arquivos:\n" >>${LOGPROC} 2>&1
			${RSYNC} ${ARQUIVOS} ${DESTINO} >>${LOGPROC} 2>&1 ## Coleta (removendo) os arquivos do NFS via rsync.
			if [ "$(saida)" -eq "0" ]; then
				echo -e ""
		elif [ "$(ls ${ARQUIVOS} |wc -l)" -eq 0 ]; then
			echo "$(data_hora) ${HOST} - Sem arquivos na origem." >>${LOGPROC} 2>&1
			exit 4
		else
			echo "$(data_hora) ${HOST} - Origem sem o mínimo de arquivos." >>${LOGPROC} 2>&1
			exit 3
		fi
	else
		echo "$(data_hora) ${HOST} - Erro na montagem do NFS." >>${LOGPROC} 2>&1
		exit 2
	fi
}

faz_backup(){
	echo -e "$(data_hora) ${HOST} - Movendo arquivos para backup:\n"
	for ARQ in $(ls ${DESTINO}/${ARQUIVOS}); do
		mv -v ${DESTINO}/${ARQ} ${BACKUP}/${ARQ}.$(timestamp) >>${LOGPROC} 2>&1
		if [ "$(saida)" -eq "0" ]; then
		echo -e ""			
}

query_lista_lojas(){
	mysql -h 52.0.8.222 -umon_flash -pmonlasa -N -B  -D monitor_flash -e "select loja from lojas;"
}

if [ "#?" -ne 1 ]; then
	echo "Utilização: ${SCRIPT} {fidelizacao|campanhas|eventos|cuponagem}"
	exit 1
fi

PARAM="$1"
PROCESSO=$(echo "${PARAM^^}")

case ${PROCESSO} in

	FIDELIZACAO)

	ORIGEM="$NFS_FILESERVER/regrasDesconto"
	ARQUIVOS="{rddet,rdgrplj,regras}.*.txt"
	DESTINO="${STATX}/FIDELIZACAO"
	BACKUP="${DESTINO}/BACKUP"
	LOGPROC="/DSOP/DLOG/${SCRIPT%.*}.${PROCESSO}.log"
	MIN="3"