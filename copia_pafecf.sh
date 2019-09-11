#!/bin/bash
#
ARQ=$1
DATA=$(date "+%F %T")
DIRORIG="/SEFAZ/LOJAS"
DIRDTN="/SEFAZ/PAF-ECF"

for LINE in $(cat ${ARQ}); do
	LJ=$(echo ${LINE} |cut -d';' -f1)
	ECF=$(echo ${LINE} |cut -d';' -f2)
	DIA=$(echo ${LINE} |cut -d';' -f3)
	MAA=$(echo ${LINE} |cut -d';' -f4)
	PAF="${ECF}${DIA}${MAA}"
	LOG="/home/wefix007/PAF_${LJ}.log"
	DTNLJ="${DIRDTN}/L${LJ}/${MAA}"
	mkdir -pv ${DTNLJ} >>${LOG} 2>&1
	ls ${DIRORIG}/L${LJ}/*/*${PAF}.txt.bz2 >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		cp -v ${DIRORIG}/L${LJ}/*/*${PAF}.txt.bz2 ${DTNLJ} >>${LOG} 2>&1
	else
		echo "Arquivo ${PAF} não encontrado." >>${LOG}
	fi		
done