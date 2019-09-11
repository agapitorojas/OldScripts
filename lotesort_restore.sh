#!/bin/bash

DIRSORT="/lasa/usr/COMNC/STARX/LOTESORT"
DIRTEMP="${DIRSORT}/TEMP"
LOTETMP=$(ls ${DIRSORT}/TEMP/T_lote* 2>/dev/null |wc -l)

conta_arquivos() {
    quantidade_arquivos=$(find ${DIRTEMP} -maxdepth 1 -type f -name "T_lote*.${data_temp}.*" 2>/dev/null |wc -l)
}

if [ $# -eq 1 -a $1 == "-a" ]; then
    find ${DIRTEMP} -maxdepth 1 -type f -name "T_lote*" -exec mv {} ${DIRSORT} \; 2>/dev/null
elif [ $# -eq 0 ]; then
    if [ ! -d ${DIRTEMP} -o ${LOTETMP} -eq 0 ]; then
        pusopo14 "Nenhum arquivo para restaurar - tecle <ENTRA> para continuar"
        exit 0
    fi
    trap "" 2 3 15
    set -ah
    set +fu

    tput cup 2 0

    . pusopg04 $DIAL/TUSOPO032

    tput clear
    tput cup 2 0

    case ${data_temp} in
        [0-9][0-9][0-9][0-9][0-9][0-9])
            conta_arquivos
            if [ ${quantidade_arquivos} -gt 0 ]; then
                find ${DIRTEMP} -maxdepth 1 -type f -name "T_lote*.${data_temp}.*" -exec mv {} ${DIRSORT} \; 2>/dev/null
                EXIT=$?
                if [ ${EXIT} -eq 0 ]; then
                    pusopo14 "${data_temp}: ${quantidade_arquivos} arquivos restaurados\nTecle <ENTRA> para continuar"
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
fi