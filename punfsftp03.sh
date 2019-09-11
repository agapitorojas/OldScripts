#!/bin/bash
: '
	Script de envio do arquivo "STG_COMP_PRICE" do IBMSAP04 para o LASAFTP2.

	Usado como modelo o "punfsmnt04".
	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
	 
	Versão: 1.0 - 26/07/2016
'

ORIG="/nfs/ibmsap04_statx_bi/RPO_SAS"
DTN="/lasa/home/rpo/get"
DATE=$(date "+%F %T")
LOG="/DSOP/DLOG/"$(basename $0)".log"

envia_arquivo (){
	cd ${ORIG}
	if [ $? -eq 0 ]; then
		if [ $(ls ${ORIG}/$1 |wc -l 2>&-) -gt 0 ]; then
			rsync -avz --chmod=ugo=rwX --progress --timeout=30 ${ORIG}/$1 lasaftp2:${DTN} >>${LOG} 2>&1
			if [ $? -ne 0 ]; then
				echo "Erro $? no RSYNC." >>${LOG} 2>&1
			else
				echo -e "\nArquivo $1 transmitido com sucesso.\n" >>${LOG} 2>&1
			fi
		else
			echo -e "\nArquivo $1 não encontrado.\n" >>${LOG} 2>&1
		fi	
	else
		echo "Erro na montagem do NFS." >>${LOG} 2>&1
	fi
}

timestamp (){
	date '+%F %T'
}

echo -e "$(timestamp) - INICIO:\n" >>${LOG} 2>&1

for ARQ in STG_COMP_PRICE.txt; do
	envia_arquivo ${ARQ}
done		

echo -e "\n$(timestamp) - FIM:\n" >>${LOG} 2>&1