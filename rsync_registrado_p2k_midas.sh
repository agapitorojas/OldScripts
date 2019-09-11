#!/bin/ksh
####################################################################################################
#
#	Script de integracao de arquivos entre FS do P2K e a Tesouraria
#	Autor: Agapito Rojas (agapito.rojas@lasa.com.br)
#
#	Versao 1.0 (25/04/2018)
#   Versao 1.1 (17/07/2018)
#       - Inclusao da funcao de verificacao Midas
#       - Incluida transmicao para o Midas
#	Versao 1.2 (10/05/2019)
#		- Separado backup em diretorios por loja
#
####################################################################################################

BASE=`basename $0` ## Nome do script
DIRBKP="/RSYNC/ARCHIVE/TESOURARIA" ## Diretorio de backup
DIRFS="/RSYNC/P2K/EP" ## NFS para o LXLASAFS01
DIRMIDAS="/var/tesouraria/files/filewatcher/current" ## Diretório remoto do Midas
DIRTES="/RSYNC/IBMFARM01/TESOURARIA" ## NFS para o IBMFARM01
LISTAMIDAS="/DSOP/DTAB/LOJAS_MIDAS" ## Lista de lojas Midas
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Log com base no nome do script
MLOG="/DSOP/DLOG/${BASE%%.*}_midas.log" ## Log de lojas Midas
PIDFILE="/DSOP/DLOG/${BASE%%.*}.pid" ## Arquivo de PID
SRVMIDAS="10.223.2.182" ## IP do servidor do Midas
USRMIDAS="ftpman" ## Usuario remoto do Midas

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

verifica_pid
verifica_tab_midas

if [ "`mount |grep ${DIRFS} |wc -l`" -eq "0" ]; then
	echo "`date \"+%F %T\"` - NFS do FS desmontado." >>${LOG} 2>&1
	exit 1
fi

if [ "`mount |grep ${DIRTES} |wc -l`" -eq "0" ]; then
	echo "`date \"+%F %T\"` - NFS da Tesouraria desmontado." >>${LOG} 2>&1
	exit 2
fi

if [ ! -s ${LISTAMIDAS} ]; then
    echo "`date \"+%F %T\"` - Lista de lojas Midas nao encontrada." >>${LOG} 2>&1
    exit 3
fi

[ ! -d ${DIRBKP} ] && mkdir -p ${DIRBKP} >/dev/null 2>&1

echo "`date \"+%F %T\"` - Inicio\n" >>${LOG} 2>&1
echo "`date \"+%F %T\"` - Inicio\n" >>${MLOG} 2>&1

for DIRLJ in `ls -d ${DIRFS}/LJ????`; do
	LJ=${DIRLJ#*LJ}
    verifica_midas ${LJ}
	if [ "`find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) 2>/dev/null |wc -l`" -gt "0" ]; then
		[ ! -d ${DIRBKP}/LJ${LJ} ] && mkdir -p ${DIRBKP}/LJ${LJ} >/dev/null 2>&1
        if [ ${MIDAS} -eq 1 ]; then
		    echo "`date \"+%F %T\"` - LOJA ${LJ} MIDAS\n" >>${LOG} 2>&1
			echo "`date \"+%F %T\"` - LOJA ${LJ}\n" >>${MLOG} 2>&1
        else
            echo "`date \"+%F %T\"` - LOJA ${LJ}\n" >>${LOG} 2>&1
        fi
        if [ ${MIDAS} -eq 1 ]; then
			find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) -exec rsync -cgopq --timeout=30 {} ${DIRBKP}/LJ${LJ} \; >>${LOG} 2>&1 && \
			find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) -exec rsync -cgopv --timeout=30 {} ${USRMIDAS}@${SRVMIDAS}:${DIRMIDAS} \; >>${MLOG} 2>&1 && \
			find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) -exec rsync -cgopv --remove-source-files --timeout=30 {} ${DIRTES} \; >>${LOG} 2>&1
		else
			find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) -exec rsync -cgopq --timeout=30 {} ${DIRBKP}/LJ${LJ} \; >>${LOG} 2>&1 && \
			find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) -exec rsync -cgopv --remove-source-files --timeout=30 {} ${DIRTES} \; >>${LOG} 2>&1
		fi
		echo >>${LOG}
	fi
done

echo "`date \"+%F %T\"` - Fim\n" >>${LOG} 2>&1
echo "`date \"+%F %T\"` - Fim\n" >>${MLOG} 2>&1

unset MIDAS
rm -f ${PIDFILE}
##Fim do script