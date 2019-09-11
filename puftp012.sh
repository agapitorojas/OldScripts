#!/bin/bash
##########################################################################
#
#	Script de envio de arquivos do SAP para LASAFS.
#
#	Usado como modelo o "puftp010".
#	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
#	 
##########################################################################
ORIG="/nfs/ibmsap04_statx_bi"
DTN="/smb/LASAFS_ARQS_RELS"
DATE=$(date "+%F %T")
YESTERDAY=$(date -d "yesterday" +%Y%m%d)
LOG="/DSOP/DLOG/"$(basename $0)".log"

envia_arquivo (){
	cd ${ORIG}
	if [ $? -eq 0 ]; then
		cd ${DTN}
		if [ $? -eq 0 ]; then
			if [ $(ls ${ORIG}/$1 |wc -l 2>&-) -gt 0 ]; then
				rsync -acvz --progress --timeout=30 ${ORIG}/$1 . >>${LOG} 2>&1
				if [ $? -ne 0 ]; then
					echo "Erro no RSYNC." >>${LOG} 2>&1
				fi
			else
				echo "Arquivo $1 não encontrado." >>${LOG} 2>&1
			fi
		else
			echo "Erro na montagem do SMB."	
		fi	
	else
		echo "Erro na montagem do NFS." >>${LOG} 2>&1
	fi
}

echo -e "${DATE} - INICIO:\n" >>${LOG} 2>&1

for ARQ in pige_estoque_8000_????????????.csv pige_estoque_9000_????????????.csv P9000_ESTQ_TERC_CDS.????????.??????.csv P9000_MTPV.????????.??????.csv P9000_NFS_ENT_SAI_CD.????????.??????.csv P9000_TRNT_TRNSF_L???.????????.??????.csv Transito.Devolucao_F9.L???.??????.??????.TXT ESTQ_ETIQ.????????.??????.csv; do
	envia_arquivo ${ARQ}
done

echo -e "\n${DATE} - FIM:\n" >>${LOG} 2>&1