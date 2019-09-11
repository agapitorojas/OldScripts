#!/bin/bash
<<HEADER
    SCRIPT: RF_SAFE-FAI_016.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para transmitir arquivos de garantia roubo e furto (RF) do SAFE-FAI para o SFTP
    VERSION:
        1.0 (09/08/2018)
        1.1 (30/11/201)
    HISTORY:
        v1.1 - Projeto "Transferência automática de arquivo RF Generali X Cubo de Seguros e BKP SAFE"
HEADER

BASE=$(basename $0) ## Nome do script
DIRSAFE="/smb/LASA-FAIPAPP01_SAFE_FAI" ## Diretório de montagem do SAFE-FAI
DIRSAP="/nfs/ibmsap04_statx_bi" ## Diretório de montagem do SAP
DIRSBKP="${DIRSAFE}/016/BKP" ## Diretório de backup
DIRSCE02="/smb/ENTRADA_LASASCE02_GE_SAFE" ## Diretóroio de montagem da GE
DIRSFTP="/lasa/home/generali" ## Diretório no servidor SFTP
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Arquivo de log

dt_time(){
    date '+%F %T'
}

if ($(ls -d ${DIRSAFE}/016 >/dev/null 2>&1)); then
    if [ "$(find ${DIRSAFE}/016 -maxdepth 1 -type f -name RF????????????????????.??? 2>/dev/null |wc -l)" -gt "0" ]; then
        echo -e "$(dt_time) - Início" >>${LOG} 2>&1
        rsync -cgopq --timeout=10 ${DIRSAFE}/016/RF????????????????????.??? ${DIRSBKP} >>${LOG} 2>&1 && \
        rsync -cgopq --timeout=10 ${DIRSAFE}/016/RF????????????????????.??? ${DIRSCE02} >>${LOG} 2>&1 && \
        rsync -cpq --timeout=10 ${DIRSAFE}/016/RF????????????????????.??? ${DIRSAP} >>${LOG} 2>&1 && \
        rsync --remove-source-files -cgopv --timeout=10 ${DIRSAFE}/016/RF????????????????????.??? lasaftp2:${DIRSFTP}/get >>${LOG} 2>&1
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
    echo -e "$(dt_time) - Erro ao acessar SAFA-FAI" >>${LOG} 2>&1
fi