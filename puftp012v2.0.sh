#!/bin/bash
##########################################################################
#
#	Script de envio de arquivos do SAP para LASAFS.
#
#	Usado como modelo o "puftp010".
#	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
#	 
#	Versão: 2.0
#			- Alterado o nome do script de "puftp12" para "punfsmnt04"
#			- Criadas variáveis para o dia corrente
#			- Alterado rsync para não manter timestamp
#			- Alterado rsync para apenas arquivos do dia corrente
#			- Incluído expurgo dos arquivos com mais de 7 dias
#			2.1
#			- Alterado data para dia anterior a pedido do usuário
##########################################################################
ORIG="/nfs/ibmsap04_statx_bi"
DTN="/smb/LASAFS_ARQS_RELS"
DATE=$(date "+%F %T")
DATE2A=$(date -d "yesterday" +%y%m%d)
DATE4A=$(date -d "yesterday" +%Y%m%d)
LOG="/DSOP/DLOG/"$(basename $0)".log"

envia_arquivo (){
	cd ${ORIG}
	if [ $? -eq 0 ]; then
		cd ${DTN}
		if [ $? -eq 0 ]; then
			if [ $(ls ${ORIG}/$1 |wc -l 2>&-) -gt 0 ]; then
				rsync -vgopz --progress --timeout=30 ${ORIG}/$1 . >>${LOG} 2>&1
				if [ $? -ne 0 ]; then
					echo "Erro $? no RSYNC." >>${LOG} 2>&1
				else
					echo -e "\nArquivos $1 transmitidos com sucesso.\n" >>${LOG} 2>&1
				fi
			else
				echo -e "\nArquivos $1 não encontrados.\n" >>${LOG} 2>&1
			fi
		else
			echo "Erro na montagem do SMB."	>>${LOG} 2>&1
		fi	
	else
		echo "Erro na montagem do NFS." >>${LOG} 2>&1
	fi
}

echo -e "${DATE} - INICIO:\n" >>${LOG} 2>&1

for ARQ in pige_estoque_8000_${DATE2A}??????.csv pige_estoque_9000_${DATE2A}??????.csv P9000_ESTQ_TERC_CDS.${DATE4A}.??????.csv P9000_MTPV.${DATE4A}.??????.csv P9000_NFS_ENT_SAI_CD.${DATE4A}.??????.csv P9000_TRNT_TRNSF_L???.${DATE4A}.??????.csv Transito.Devolucao_F9.L???.${DATE2A}.??????.TXT ESTQ_ETIQ.${DATE4A}.??????.csv; do
	envia_arquivo ${ARQ}
done

echo -e "\nRemovendo arquivos com mais de uma semana:\n" >>${LOG} 2>&1

for OLD in pige_estoque_8000_*.csv pige_estoque_9000_*.csv P9000_ESTQ_TERC_CDS.*.*.csv P9000_MTPV.*.*.csv P9000_NFS_ENT_SAI_CD.*.*.csv P9000_TRNT_TRNSF_L*.*.*.csv Transito.Devolucao_F9.L*.*.*.TXT ESTQ_ETIQ.*.*.csv; do
	find ${DTN} -maxdepth 1 -type f -name ${OLD} -mtime +7 -exec rm -fv {} \; >>${LOG} 2>&1
done		

echo -e "\n${DATE} - FIM:\n" >>${LOG} 2>&1