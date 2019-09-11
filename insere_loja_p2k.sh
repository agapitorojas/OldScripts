#!/bin/bash
: '
	Script para inclusão de nova loja P2K às rotinas e criação das filas de impressão no Fileserver P2K.

	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
	Versão: 1.0 - 01/07/2016
'

[ $# -lt 1 ] && echo "Uso: insere_loja_p2k.sh [nº da loja]" ## Testa a quandidade de parâmetros
for PARAM in "$@"; do ## Testa o tamanho dos parâmetros
	NCHAR=${#PARAM}
	if [ ${NCHAR} -le 4 ]; then
		LOJA=${PARAM}
	else
		echo -e "\e[1;31m${PARAM}: O nº da loja deve ter até 4 caracteres\033[0m"
	fi
done