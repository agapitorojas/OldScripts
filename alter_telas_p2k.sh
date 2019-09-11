#!/bin/bash
#
DATA=$(date +%Y%m%d)
LOJA=$(hostname |cut -c6-)
[ "${LOJA}" -lt "1000" ] && LOJA=0${LOJA}

cd /p2ksp/sp_lj${LOJA}/atualizacaoComponente
if [ "$?" -eq "0" ]; then
	if [ -s /tmp/telas.zip ]; then
		mv -v telas telas.${DATA} 2>&-
		unzip /tmp/telas.zip && \
		chown p2ksp:p2ksp -R telas && \
		echo -e "\nTelas alteradas com sucesso."
	else
		echo "Arquivo não encontrado."
	fi
else
	echo "Diretório destino não encontrado."
fi