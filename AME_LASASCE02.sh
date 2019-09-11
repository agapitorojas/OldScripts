#!/bin/bash
<<HEADER
    SCRIPT: AME_LASASCE02.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para transmitir arquivos de AME DIGITAL do SFTP para o LASASCE02
    VERSION: 1.0 (29/10/2018)
    HISTORY:
HEADER

BASE=$(basename $0) ## Nome do script
DIRSCE02="/smb/ENTRADA_LASASCE02_AME_DIGITAL" ## Diretório de montagem do LASASCE02
DIRSFTP="/LOCAL_STARX/SERVIDOR_FTP/amedigital" ## Diretório de coleta do servidor SFTP
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Arquivo de log

dt_time(){
    date '+%F %T'
}

if ($(ls -d ${DIRSCE02} >/dev/null 2>&1)); then
    if [ "$(find ${DIRSFTP} -maxdepth 1 -type f -name [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_ame_[A-Z][A-Z]_[0-9].txt 2>/dev/null |wc -l)" -gt "0" ]; then
        echo -e "$(dt_time) - Início" >>${LOG} 2>&1
        rsync --remove-source-files -cgopv --timeout=10 ${DIRSFTP}/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_ame_[A-Z][A-Z]_[0-9].txt ${DIRSCE02} >>${LOG} 2>&1
        EXIT=$?
        if [ "${EXIT}" -eq "0" ]; then
            echo -e "$(dt_time) - Arquivos transmitidos com sucesso" >>${LOG} 2>&1
        else
            echo -e "$(dt_time) - Erro ${EXIT} ao transmitir arquivos" >>${LOG} 2>&1
        fi
    else
        echo -e "$(dt_time) - Sem arquivos para transmitir" >>${LOG} 2>&1
    fi
else
    echo -e "$(dt_time) - Erro ao acessar LASASCE02" >>${LOG} 2>&1
fi
## Fim do script