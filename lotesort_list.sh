#!/bin/bash
<<HEADER
        Lista arquivos T_lote* no diretório "/lasa/usr/COMNC/STARX/LOTESORT"

        Versao 1.0 (03/05/2018)
HEADER

DIRSORT="/lasa/usr/COMNC/STARX/LOTESORT"
HOJE=$(date +%y%m%d)
LOTESORT=$(ls ${DIRSORT}/T_lote* 2>/dev/null |wc -l))
LOTETMP=$(ls ${DIRSORT}/TEMP/T_lote* 2>/dev/null |wc -l)

if [ ${LOTESORT} -eq 0 ]; then
    pusopo14 "Nenhum arquivo para mover - tecle <ENTRA> para continuar"
    exit 0
fi

trap "" 2 3 15
set -ah
set +fu

tput cup 2 0
tput clear

echo -e "\033[1mA PROCESSAR:\e[0m\n"
echo -e "\033[1mDATA\tARQUIVOS\e[0m"
for DATA in $(find ${DIRSORT} -maxdepth 1 -type f -name "T_lote*" -printf "%f\n" |cut -d. -f2 |sort |uniq); do
        [ ${DATA} -ge ${HOJE} ] && COR="\e[91m" || COR="\e[92m"
        ARQ=$(ls ${DIRSORT}/T_lote*.${DATA}.* |wc -l)
        echo -e "${COR}${DATA}\t${ARQ}\e[0m"
done

if [ -d ${DIRSORT}/TEMP -a ${LOTETMP} -gt 0 ]; then
    echo -e "\n\033[1mARQUIVADOS:\e[0m\n"
    echo -e "\033[1mDATA\tARQUIVOS\e[0m"
    for DATATMP in $(find ${DIRSORT}/TEMP -maxdepth 1 -type f -name "T_lote*" -printf "%f\n" |cut -d. -f2 |sort |uniq); do
        [ ${DATATMP} -ge ${HOJE} ] && COR="\e[91m" || COR="\e[92m"
        ARQTMP=$(ls ${DIRSORT}/TEMP/T_lote*.${DATATMP}.* |wc -l)
        echo -e "${COR}${DATATMP}\t${ARQTMP}\e[0m"
    done
fi
pusopo14 "Tecle <ENTRA> para continuar"