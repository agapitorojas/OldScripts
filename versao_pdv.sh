#!/bin/bash
: '

	Script para verificar a versão dos PDVs ativos na loja.

	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
	Versão: 1.0 (30/06/2016)
	Versão: 1.1 (19/07/2016)
	- Inclusão de funções
	- Inclusão da data de modificação dos arquivos "rtcd???"
'
LPDVS="/lasa/pdvs"
DADOS="${LPDVS}/dados"

pdvs_ativos (){
	find ${LPDVS}/bk[0-9][0-9][0-9] -maxdepth 1 -type f -mtime -31 -name "lgcx*" |cut -c22-24 |sort |uniq ## Gera lista de pdvs com log nos últimos 30 dias 
}

dados_arquivos (){
	PDV=$1
	RTCD="${DADOS}/rtcd${PDV}"
	if [ -s ${RTCD} ]; do
		VER=$(head -n1 ${RTCD} 2>/dev/null |cut -c109-115)
		DATA=$(stat -c '%y' ${RTCD} 2>/dev/null |cut -d. -f1 |awk '{print $1}')
		HORA=$(stat -c '%y' ${RTCD} 2>/dev/null |cut -d. -f1 |awk '{print $2}')
		echo "${PDV} ${VER} ${DATA} ${HORA}"
	done
}

if [ -f /DSOP/DTAB/EH_P2K_TOTAL ]; then
	echo "P2K TOTAL"
	exit 0
else
	for PDVS in $(pdvs_ativos); do
		dados_arquivos ${PDVS}
	done
fi