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
#       Versao 1.2 (25/07/2018)
#       - Inclusao da funcao de verificacao Midas
#       - Incluida transmicao para o Midas
#
####################################################################################################
BASE=`basename $0` ## Nome do script
DIRBKP="/RSYNC/ARCHIVE/TESOURARIA" ## Diretorio de backup
DIRMIDAS="/var/tesouraria/files/filewatcher/current" ## Diretorio remoto do Midas
DIRSTATX="/lasa/usr/COMNC/STATX/PI" ## Diretorio remoto na loja
DIRTES="/RSYNC/IBMFARM01/TESOURARIA" ## NFS para o IBMFARM01
DIRTXMIDAS="/RSYNC/MIDAS/TX"
LISTAMIDAS="/DSOP/DTAB/LOJAS_MIDAS" ## Lista de lojas Midas
LISTAPRISMA="/DSOP/DTAB/LOJAS_PRISMA.csv" ## Lista de lojas Prisma
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Log com base no nome do script
MLOG="/DSOP/DLOG/${BASE%%.*}_midas.log" ## Log de lojas Midas
PIDFILE="/DSOP/DLOG/${BASE%%.*}.pid" ## Arquivo de PID
SSH="ssh -q -o ConnectTimeout=15 -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no"
SRVMIDAS="10.223.2.182" ## IP do servidor do Midas
USRMIDAS="ftpman" ## Usuario remoto do Midas

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

function coleta_midas {
    LOJA=$1
    ORIGEM=$2
    echo "LOJA ${LOJA} MIDAS\n"
    rsync -cgop -e "${SSH}" --include='[lL][fF][iI][nN]*' --include='[lL][oO][uU][tT]*' --include='[lL][rR][iI][nN]*' --include='[lL][vV][dD][eE][pP]*' --include='[tT][eE][sS]*' --exclude='*' --timeout=30 ${ORIGEM}/* ${DIRBKP} && \
    rsync -cgop -e "${SSH}" --include='[lL][fF][iI][nN]*' --include='[lL][oO][uU][tT]*' --include='[lL][rR][iI][nN]*' --include='[lL][vV][dD][eE][pP]*' --include='[tT][eE][sS]*' --exclude='*' --timeout=30 ${ORIGEM}/* ${DIRTXMIDAS} && \
    rsync -cgopv -e "${SSH}" --include='[lL][fF][iI][nN]*' --include='[lL][oO][uU][tT]*' --include='[lL][rR][iI][nN]*' --include='[lL][vV][dD][eE][pP]*' --include='[tT][eE][sS]*' --exclude='*' --remove-source-files --timeout=30 ${ORIGEM}/* ${DIRTES} && \
    ERRO=$?
    if [ ${ERRO} -eq 0 ]; then
        echo "\n`date \"+%F %T\"` - OK\n"
    else
        echo "\n`date \"+%F %T\"` - ERRO ${ERRO}\n"
    fi
}

function transmite_midas {
    echo "`date \"+%F %T\"` - Transmitindo arquivos para o Midas:"
    find ${DIRTXMIDAS}/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) -exec rsync -cgopv --remove-source-files --timeout=30 {} ${USRMIDAS}@${SRVMIDAS}:${DIRMIDAS} \;
    ERRO=$?
    if [ ${ERRO} -eq 0 ]; then
        echo "\n`date \"+%F %T\"` - Arquivos transmitidos com sucesso.\n"
    else
        echo "\n`date \"+%F %T\"` - ERRO ${ERRO} na transmissao para o Midas.\n"
    fi
}

function verifica_midas {
    LJMIDAS=$1
    if [ `grep -w ${LJMIDAS} ${LISTAMIDAS} |wc -l` -eq 1 ]; then
        MIDAS=1
    else
        MIDAS=0
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

function verifica_tab_midas {
    MD5LOCAL="`csum /DSOP/DTAB/LOJAS_MIDAS 2>/dev/null |awk '{print $1}'`"
    MD5REMOTO="`ssh -o ConnectTimeout=10 rsync@lxlasa11 'md5sum /DSOP/DTAB/LOJAS_MIDAS 2>/dev/null' |awk '{print $1}'`"
    if [[ ${MD5LOCAL} != ${MD5REMOTO} ]]; then
        rsync -cgopq --timeout=30 rsync@lxlasa11:/DSOP/DTAB/LOJAS_MIDAS /DSOP/DTAB 2>/dev/null
        ERRO=$?
        if [ ${ERRO} -ne 0 ]; then
            echo "\n`date \"+%F %T\"` - ERRO ${ERRO} ao atualizar lista MIDAS." >>${LOG} 2>&1
        fi
    fi
}

function verifica_tab_prisma {
    MD5LOCAL="`csum /DSOP/DTAB/LOJAS_PRISMA.csv 2>/dev/null |awk '{print $1}'`"
    MD5REMOTO="`ssh -o ConnectTimeout=10 rsync@lxlasa11 'md5sum /DSOP/DTAB/LOJAS_PRISMA.csv 2>/dev/null' |awk '{print $1}'`"
    if [[ ${MD5LOCAL} != ${MD5REMOTO} ]]; then
        rsync -cgopq --timeout=30 rsync@lxlasa11:/DSOP/DTAB/LOJAS_PRISMA.csv /DSOP/DTAB 2>/dev/null
        ERRO=$?
        if [ ${ERRO} -ne 0 ]; then
            echo "\n`date \"+%F %T\"` - ERRO ${ERRO} ao atualizar lista Prisma." >>${LOG} 2>&1
        fi
    fi
}

verifica_pid
verifica_tab_prisma
verifica_tab_midas

if [ "`mount |grep ${DIRTES} |wc -l`" -eq "0" ]; then
    echo "`date \"+%F %T\"` - NFS da Tesouraria desmontado." >>${LOG} 2>&1
    exit 1
fi

if [ ! -s ${LISTAPRISMA} ]; then
    echo "`date \"+%F %T\"` - Lista de lojas Prisma nao encontrada." >>${LOG} 2>&1
    exit 2
fi

if [ ! -s ${LISTAMIDAS} ]; then
    echo "`date \"+%F %T\"` - Lista de lojas Midas nao encontrada." >>${LOG} 2>&1
    exit 3
fi

echo "`date \"+%F %T\"` - Inicio\n" >>${LOG} 2>&1
echo "`date \"+%F %T\"` - Inicio\n" >>${MLOG} 2>&1

awk -F\; '{print $1,$2}' /DSOP/DTAB/LOJAS_PRISMA.csv | \
while read LINHA; do 
    set ${LINHA}
    LJ=$1
    IP=$2
    verifica_midas ${LJ}
    if [ ${MIDAS} -eq 1 ]; then
        LOGLJ="/DSOP/DLOG/${BASE%%.*}_midas.${LJ}.log"
        echo "LOJA ${LJ} ${IP} `date +%T`" >>${LOG} 2>&1
        echo "LOJA ${LJ} ${IP} `date +%T`" >>${MLOG} 2>&1
        coleta_midas ${LJ} rsync@${IP}:${DIRSTATX} >>${LOGLJ} 2>&1
    else
        LOGLJ="/DSOP/DLOG/${BASE%%.*}.${LJ}.log"
        echo "LOJA ${LJ} ${IP} `date +%T`" >>${LOG} 2>&1
        coleta ${LJ} rsync@${IP}:${DIRSTATX} >>${LOGLJ} 2>&1
    fi
done

transmite_midas >>${MLOG} 2>&1

echo "\n`date \"+%F %T\"` - Fim\n" >>${LOG} 2>&1
echo "\n`date \"+%F %T\"` - Fim\n" >>${MLOG} 2>&1

unset MIDAS
rm -f ${PIDFILE}
## Fim do script