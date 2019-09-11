#!/bin/bash

ORIG="/nfs/ibmsap04_statx_bi"
DTN="/lasa/home/nielsen/get"
DATE=$(date "+%F %T")
YESTERDAY=$(date -d "yesterday" +%Y%m%d)
LOG="/DSOP/DLOG/"$(basename $0)".log"

envia_arquivo (){
	cd ${ORIG}
	if [ $? -eq 0 ]; then
		if [ $(ls $1 |wc -l 2>&-) -gt 0 ]; then
			rsync -vgopz --progress --timeout=30 $1 lasaftp2:${DTN} >>${LOG} 2>&1
			if [ $? -ne 0 ]; then
				echo "Erro no RSYNC." >>${LOG} 2>&1
			fi	
		else
			echo "Arquivo $1 não encontrado." >>${LOG} 2>&1
		fi
	else
		echo "Erro na montagem do NFS." >>${LOG} 2>&1
	fi
}

echo -e "${DATE} - INICIO:\n" >>${LOG} 2>&1

for ARQ in departamento_novo_${YESTERDAY}.txt lojas_novo_${YESTERDAY}.txt movimento_novo_${YESTERDAY}.txt vendas_contabeis_novo_${YESTERDAY}.txt; do
	envia_arquivo ${ARQ}
done

echo -e "\n${DATE} - FIM:\n" >>${LOG} 2>&1
