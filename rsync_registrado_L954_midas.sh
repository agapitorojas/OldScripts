#!/bin/ksh
####################################################################################################
#
#       Script de integracao de arquivos Resgistrados da loja #954 e o Midas
#       Autor: Agapito Rojas (agapito.rojas@lasa.com.br)
#
#       Versao 1.0 (25/10/2018)
#
####################################################################################################
BASE=`basename $0` ## Nome do script
DIRBKP="/RSYNC/ARCHIVE/TESOURARIA" ## Diretorio de backup
DIRMIDAS="/var/tesouraria/files/filewatcher/current" ## Diretorio remoto do Midas
DIRTXMIDAS="/RSYNC/MIDAS/TX"
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Log de lojas Midas
ORIGEM="rsync@lxlasa11:/home/hydra/get/tesouraria/L954"
PIDFILE="/DSOP/DLOG/${BASE%%.*}.pid" ## Arquivo de PID
SSH="ssh -q -o ConnectTimeout=15 -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no"
SRVMIDAS="10.223.2.182" ## IP do servidor do Midas
USRMIDAS="ftpman" ## Usuario remoto do Midas

function transmite_L954_midas {
    echo "LOJA 0954\n"
    rsync -cgop -e "${SSH}" --include='[lL][fF][iI][nN]*' --include='[lL][oO][uU][tT]*' --include='[lL][rR][iI][nN]*' --include='[lL][vV][dD][eE][pP]*' --include='[tT][eE][sS]*' --exclude='*' --timeout=30 ${ORIGEM}/* ${DIRBKP} && \
    rsync -cgop -e "${SSH}" --include='[lL][fF][iI][nN]*' --include='[lL][oO][uU][tT]*' --include='[lL][rR][iI][nN]*' --include='[lL][vV][dD][eE][pP]*' --include='[tT][eE][sS]*' --exclude='*' --remove-source-files --timeout=30 ${ORIGEM}/* ${DIRTXMIDAS} && \
    find ${DIRTXMIDAS}/* -prune -type f \( -name lfin*.0954 -o -name lout*.0954 -o -name lrin*.0954 -o -name LVDEP*.0954 -o -name tes*.0954 \) -exec rsync -cgopv --remove-source-files --timeout=30 {} ${USRMIDAS}@${SRVMIDAS}:${DIRMIDAS} \;
    ERRO=$?
    if [ ${ERRO} -eq 0 ]; then
        echo "\n`date \"+%F %T\"` - Arquivos transmitidos com sucesso.\n"
    else
        echo "\n`date \"+%F %T\"` - ERRO ${ERRO} na transmissao para o Midas.\n"
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

verifica_pid

echo "`date \"+%F %T\"` - Inicio\n" >>${LOG} 2>&1

transmite_L954_midas >>${LOG} 2>&1

echo "\n`date \"+%F %T\"` - Fim\n" >>${LOG} 2>&1

rm -f ${PIDFILE}
## Fim do script