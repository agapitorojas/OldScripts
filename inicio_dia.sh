#!/bin/bash
####################################################################################################
#
#	Script de início de dia automático de Retaguarda/Vanguarda.
#	Programas acionados:
#	- pusopo12 (Exporta variáveis)
#	- sgc70003 (Início de dia da Retaguarda)
#	- sup01030 (Início de dia da Vanguarda)
#
#	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
#	Revisor: Felipe Motta (felipe.motta@lasa.com.br)
#
#	Versão 1.0 (01/06/2016)
#	Versão 1.1 (06/06/2016)
#		- Corrigido o timestamp da execução dos programas
#		- Incluído o pusopo12
#	Versão 1.2 (11/07/2016)
#		- Inclusão da variável "SAIDA"
#	Versão 1.3 (03/08/2016)
#		- Início de Vanguarda independente da Retaguarda
#	Versão 1.4 (31/10/2016)
#		- Desconsiderada a saída 9 do COBOL
#	Versão 1.5 (20/03/2017)
#		- Incluída verificação de loja P2K
#
####################################################################################################
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1
FILE=$(basename $0)
HOST=$(hostname)
LOG=/DSOP/DLOG/${FILE%.*}.log
LOJA=$(hostname |cut -d_ -f2)
TIME=$(date '+%F %T')

timestamp (){
	date '+%F %T'
}

if [ -f /DSOP/DTAB/EH_P2K_TOTAL ]; then
	echo "$(timestamp) ${HOST}: Loja P2K Total" >>${LOG}
	exit 0
fi

export COBSW=-F
export COBDIR=/opt/microfocus/cobol/
export LIBPATH=$COBDIR/lib:$LIBPATH:/usr/lib
export TERM=vt100

if [ $(pgrep -x sgc70003 |wc -l) -ge 1 ]; then
	echo "$(timestamp) ${HOST}: Já existe sgc70003 em execução" >>${LOG}
	exit 1
fi
if [ $(pgrep -x sup01030 |wc -l) -ge 1 ]; then
	echo "$(timestamp) ${HOST}: Já existe sup01030 em execução" >>${LOG}
	exit 2
fi

echo "$(timestamp) ${HOST}: Início de dia iniciado" >>${LOG}
echo "$(timestamp) ${HOST}: Iniciando a Retaguarda" >>${LOG}
cd /lasa1/pdvs/dados
./exec/sgc70003
SAIDA=$?
if [ ${SAIDA} -eq 0 -o ${SAIDA} -eq 9 ]; then
	echo "$(timestamp) ${HOST}: Retaguarda iniciada com sucesso" >>${LOG}
else
	echo "$(timestamp) ${HOST}: Erro ${SAIDA} ao iniciar a Retaguarda" >>${LOG}
fi

echo "$(timestamp) ${HOST}: Iniciando a Vanguarda" >>${LOG}
cd /lasa/pdvs/dados
./exec/sup01030
SAIDA=$?
if [ ${SAIDA} -eq 0 -o ${SAIDA} -eq 9 ]; then
	echo "$(timestamp) ${HOST}: Vanguarda iniciada com sucesso" >>${LOG}
else
	echo "$(timestamp) ${HOST}: Erro ${SAIDA} ao iniciar a Vanguarda" >>${LOG}
fi
echo "$(timestamp) ${HOST}: Início de dia encerrado" >>${LOG}