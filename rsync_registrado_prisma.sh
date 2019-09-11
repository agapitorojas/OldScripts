#!/bin/ksh
####################################################################################################
#
#       Script de integracao de arquivos Resgistrados do Prisma e a Tesouraria
#       Autor: Agapito Rojas (agapito.rojas@lasa.com.br)
#
#       Versao 1.0 (07/06/2018)
#       Versao 1.1 (11/06/2018)
#           - Funcao "coleta" sem execucao em background
#           - Funcao "espere" desativasa
#           - Parametros do SSH com connect timeout
#
####################################################################################################
BASE=`basename $0` ## Nome do script
DIRBKP="/RSYNC/ARCHIVE/TESOURARIA" ## Diretorio de backup
DIRSTATX="/lasa/usr/COMNC/STATX/PI" ## Diretorio remoto na loja
DIRTES="/RSYNC/IBMFARM01/TESOURARIA" ## NFS para o IBMFARM01
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Log com base no nome do script
PIDFILE="/DSOP/DLOG/${BASE%%.*}.pid" ## Arquivo de PID
SSH="ssh -q -o ConnectTimeout=15 -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no"

#function espere {
#    N=${1:-10} ## Se valor nao atribuido, utilizar "10"
#    sleep $(echo "${RANDOM} % ${N}" |bc)
#}

function coleta {
    LOJA=$1
    ORIGEM=$2
    echo "LOJA ${LOJA}\n"
#   espere 16
    rsync -cgop -e "${SSH}" --include='[lL][fF][iI][nN]*' --include='[lL][oO][uU][tT]*' --include='[lL][rR][iI][nN]*' --include='[lL][vV][dD][eE][pP]*' --include='[tT][eE][sS]*' --exclude='*' --timeout=30 ${ORIGEM}/* ${DIRBKP} && \
    rsync -cgopv -e "${SSH}" --include='[lL][fF][iI][nN]*' --include='[lL][oO][uU][tT]*' --include='[lL][rR][iI][nN]*' --include='[lL][vV][dD][eE][pP]*' --include='[tT][eE][sS]*' --exclude='*' --remove-source-files --timeout=30 ${ORIGEM}/* ${DIRTES} && \
    ERRO=$?
    if [ ${ERRO} -eq 0 ]; then
        echo "\n`date \"+%F %T\"` - OK\n"
    else
        echo "\n`date \"+%F %T\"` - ERRO ${ERRO}\n"
    fi
}

function verifica_pid {
    if [ -s ${PIDFILE} ]; then
        LASTPID=$(cat ${PIDFILE})
        if [ -d /proc/${LASTPID} ]; then
            echo "`date \"+%F %T\"` - Processo em execucao." >>${LOG} 2>&1
            exit 0
        else
            echo $$ >${PIDFILE}
        fi
    else
        echo $$ >${PIDFILE}
    fi
}

if [ "`mount |grep ${DIRTES} |wc -l`" -eq "0" ]; then
    echo "`date \"+%F %T\"` - NFS da Tesouraria desmontado." >>${LOG} 2>&1
    exit 1
fi

if [ ! -s /DSOP/DTAB/LOJAS_PRISMA.csv ]; then
    echo "`date \"+%F %T\"` - Lista de lojas nao encontrada." >>${LOG} 2>&1
    exit 2
fi

verifica_pid

echo "`date \"+%F %T\"` - Inicio\n" >>${LOG} 2>&1

awk -F\; '{print $1,$2}' /DSOP/DTAB/LOJAS_PRISMA.csv | \
while read LINHA; do 
    set ${LINHA}
    LJ=$1
    IP=$2
    LOGLJ="/DSOP/DLOG/${BASE%%.*}.${LJ}.log"
    echo "LOJA ${LJ} ${IP} `date +%T`" >>${LOG} 2>&1
    coleta ${LJ} rsync@${IP}:${DIRSTATX} >>${LOGLJ} 2>&1
done

echo "\n`date \"+%F %T\"` - Fim\n" >>${LOG} 2>&1

rm -f ${PIDFILE}
## Fim do script