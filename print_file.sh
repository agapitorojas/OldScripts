#!/bin/bash
<<HEADER

HEADER

BASE=$(basename $0)
BKPDIR=""
FILE=$1
LOG="/DSOP/DLOG/${BASE%%.*}.log"
PRINTER=$2

dt_time(){
    date "+%F %T"
}

test_printer(){
    /usr/bin/lpstat -t ${PRINTER} >/dev/null 2>&1
    [[ $? -ne 0 ]] && echo "$(dt_time) - Erro ao acessar ${PRINTER}" |tee -a ${LOG}
}

if [[ $# -ne 2 ]]; then
    echo "Uso: ${BASE} [ARQUIVO] [IMPRESSORA]"
    exit 1
fi

/usr/bin/lp -d ${PRINTER} ${FILE} >/dev/null 2>&1
EXIT=$?
if [[ "${EXIT}" -eq "0" ]]; then
    echo "$(dt_time) - Impressão com sucesso em ${PRINTER}" |tee -a ${LOG}
    mv -f ${FILE} 