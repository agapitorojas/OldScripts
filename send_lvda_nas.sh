#!/bin/bash
<<HEAD
	Script de transmissão de arquivos LVDA de lojas P2K pra o LASA-NAS
	Autor: Agapito Rojas (agapito.rojas@lasa.com.br)

	Versão 1.0 (06/04/2018)
HEAD

BASE=$(basename $0)
EPDIR="/P2K/EP"
ARRDIR=($(ls -d ${EPDIR}/LJ???? |cut -d/ -f4))
LVDANAS="/nfs/lasa_nas_lvda"
LOG="/DSOP/DLOG/${BASE%%.*}.log"

echo -e "$(date '+%F %T') - Início\n" >>${LOG} 2>&1

for LJ in ${ARRDIR[*]}; do
	NUM=${LJ#LJ*}
	if [ $(find ${EPDIR}/${LJ}/Exportacao/LVDA????????.${NUM} 2>/dev/null |wc -l) -gt 0 ]; then
		echo ${LJ} >> ${LOG}
		[ ! -d ${LVDANAS}/${LJ} ] && mkdir ${LVDANAS}/${LJ} >/dev/null 2>&1
		rsync -cgopv --remove-source-files --timeout=30 ${EPDIR}/${LJ}/Exportacao/LVDA????????.${NUM} ${LVDANAS}/${LJ} >>${LOG} 2>&1
	fi
done

echo -e "$(date '+%F %T') - Fim\n" >>${LOG} 2>&1