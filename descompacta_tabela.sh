#!/bin/bash
####################################################################################################
#
#	Script para descompactação de tabelas de vendas o Flash.
#	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
#	Versão: 1.0
#
####################################################################################################
ORG="/DATABASE/FLASH/lasahistvendas/.backup/"
DTN="/DATABASE/FLASH/TEMP"
DATA="$1"
ARQ="${ORG}vendas${DATA}.tar.bz2"

if [ $(ls ${ARQ} |wc -l) -eq 1 ]; then
	tar xjvf ${ARQ} -C ${DTN}
else
	exit 1
fi