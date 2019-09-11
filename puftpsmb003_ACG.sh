#!/bin/bash
<<INTRO

	Projeto "Novo Cartão Pré-Pago ACG". Rotina para a transferência dos arquivos de conciliação do SFTP do fornecedor ACG para o SCE.

	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)

	Versão 1.0 (09/08/2017)
INTRO

BASE=$(basename $0)
DIRDTN="/smb/ENTRADA_LASASCE02_ACG"
DIRSRC="/lasa/home/acg/put"
LOG=/DSOP/DLOG/${BASE%%.*}.log

mount_test(){
	cd ${DIRDTN}
	if [ $? -eq 0 ]; then
		if [ $(df -t cifs |grep -w "${DIRDTN}" |wc -l) -eq 1 ]; then
			return 0
		else
			return 1
		fi
	else
		return 2
	fi
}

list_files(){
	if [ $(ssh lasaftp2 "ls ${DIRSRC}/ACG_??????????????.csv 2>/dev/null |wc -l") -gt 0 ]; then
		return 0
	else
		return 3
	fi
}

echo "$(date \"+%F - %T\") - Início" >>${LOG} 2>&1
mount_test
EXIT=$?
if [ "${EXIT}" -eq "0" ]; then
	list_files
	EXIT=$?
	if [ "${EXIT}" -eq "0" ]; then
		rsync -gopv --remove-source-files lasaftp2:${DIRSRC}/ACG_??????????????.csv ${DIRDTN} >>${LOG} 2>&1
		EXIT=$?
		if [ "${EXIT}" -eq "0" ]; then
			echo "Arquivos transmitidos com sucesso" >>${LOG} 2>&1
		else
			echo "Erro ${EXIT} ao transmitir os arquivos" >>${LOG} 2>&1
		fi
	elif [ "${EXIT}" -eq 3 ]; then
		echo "Sem arquivos na origem" >>${LOG} 2>&1
	else
		echo "Erro ${EXIT} ao listar os arquivos" >>${LOG} 2>&1
	fi
else
	echo "Erro na montagem do destino" >>${LOG} 2>&1
fi
echo "$(date \"+%F - %T\") - Fim" >>${LOG} 2>&1
## Fim do script