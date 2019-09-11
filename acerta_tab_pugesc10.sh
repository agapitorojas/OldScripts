#!/bin/bash
: '
	Script para acertar a tabela "tab_pugesc10" das lojas, para garantir geração do corte parcial.

	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
	Versão: 1.0 - 26/07/2016
'

LOJA=$(hostname |cut -d_ -f2)

if [ $(grep ^${LOJA} /DSOP/DTAB/tab_pugesc10 |wc -l) -eq 0 ]; then
	echo "${LOJA}:19" >/DSOP/DTAB/tab_pugesc10 && \
	chmod 666 /DSOP/DTAB/tab_pugesc10
fi

cat /DSOP/DTAB/tab_pugesc10