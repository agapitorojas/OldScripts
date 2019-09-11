#!/bin/bash

DIRSORT="/lasa/usr/COMNC/STARX/LOTESORT"

conta_arquivos() {
    quantidade_arquivos=$(find ${DIRSORT} -maxdepth 1 -type f -name "T_lote*.${data_lotesort}.*" 2>/dev/null |wc -l)
}

trap "" 2 3 15
set -ah
set +fu

tput cup 2 0

. pusopg04 $DIAL/TUSOPO031

tput clear
tput cup 2 0

case ${data_lotesort} in
    [0-9][0-9][0-9][0-9][0-9][0-9])
        [ ! -d ${DIRSORT}/TEMP ] && mkdir -p ${DIRSORT}/TEMP
        conta_arquivos
        if [ ${quantidade_arquivos} -gt 0 ]; then
            find ${DIRSORT} -maxdepth 1 -type f -name "T_lote*.${data_lotesort}.*" -exec mv {} ${DIRSORT}/TEMP \; 2>/dev/null
            EXIT=$?
            if [ ${EXIT} -eq 0 ]; then
                pusopo14 "${data_lotesort}: ${quantidade_arquivos} arquivos movidos\nTecle <ENTRA> para continuar"
            else
                pusopo14 "Erro ${EXIT} - tecle <ENTRA> para continuar"
            fi
        else
            pusopo14 "Nenhum arquivo com esta data - tecle <ENTRA> para continuar"
            exit 0
        fi
    ;;
    *)
        pusopo14 "Informe a data no formato AAMMDD - tecle <ENTRA> para continuar"
        exit 0
    ;;
esac