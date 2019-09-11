#!/bin/bash
##########################################################################
#
#	Script de envio do arquivo "ronda_mov.txt" do SAP para o RONDA.
#
#	Usado como modelo o "punfsmnt04".
#	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
#	 
#	Versão: 1.0 - 12/05/2016
#			
##########################################################################
ORIG="/nfs/ibmsap04_starx_ronda"
DTN="/smb/RONDA-APP1_SAPxRONDA"
DATE=$(date "+%F %T")
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
					echo -e "\nArquivo $1 transmitido com sucesso.\n" >>${LOG} 2>&1
				fi
			else
				echo -e "\nArquivo $1 não encontrado.\n" >>${LOG} 2>&1
			fi
		else
			echo "Erro na montagem do SMB."	>>${LOG} 2>&1
		fi	
	else
		echo "Erro na montagem do NFS." >>${LOG} 2>&1
	fi
}

echo -e "${DATE} - INICIO:\n" >>${LOG} 2>&1

for ARQ in ronda_mov.txt; do
	envia_arquivo ${ARQ}
done		

echo -e "\n${DATE} - FIM:\n" >>${LOG} 2>&1