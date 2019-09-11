#!/bin/bash
<<HEADER
    SCRIPT: envia_backup_bloco_x_lxlasa16.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para envio dos arquivos XML para o LXLASA16
    VERSION:
        1.0 (15/05/2019)
    HISTORY:
HEADER
base=$(basename $0) ## Nome do script
log="/DSOP/DLOG/${base%%.*}.log" ## Arquivo de log
loja=$(hostname |cut -c6-)
[[ "${loja}" -lt  1000 ]] && loja=0${loja}
dir_lxlasa16="/BACKUP/LOJAS/BLOCO_X"
dir_loja="${dir_lxlasa16}/LJ${loja}"
dir_enviados="/lasa/pdvs/dados/agentws/blocox/backups"
dir_recebidos="/lasa/pdvs/dados/agentws/output"
xml_enviados=($(find ${dir_enviados} -maxdepth 1 -type f -name "xmlReducaoZ-*" -mtime +1)) ## Array dos arquivos XML enviados com mais de 24 horas
xml_recebidos=($(find ${dir_recebidos} -maxdepth 1 -type f -name "rc??????.???" -mtime +1)) ## Array dos arquivos XML recebidos com mais de 24 horas

f_rsync(){
    tipo=$1
    case ${tipo} in
        enviados)
            if [[ "${#xml_enviados[@]}" -gt "0" ]]; then
                arquivos="${xml_enviados[@]}"
            fi
        ;;
        recebidos)
            if [[ "${#xml_recebidos[@]}" -gt "0" ]]; then
                arquivos="${xml_recebidos[@]}"
            fi
        ;;
    esac
    if [[ -n ${arquivos} ]]; then
        echo "$(date '+%F %T') - Transmitindo arquivos XML ${tipo}" >>${log} 2>&1
        rsync -cgopv --remove-source-files --rsync-path="mkdir -p ${dir_loja}/${tipo} && rsync" --timeout=30 ${arquivos} lxlasa16:${dir_loja}/${tipo} >>${log} 2>&1
        unset arquivos
    else
        echo "$(date '+%F %T') - Sem arquivos ${tipo} para transmitir" >>${log} 2>&1
    fi
}

f_rsync enviados
f_rsync recebidos
## Fim do script