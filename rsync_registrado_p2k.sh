#!/bin/ksh
####################################################################################################
#
#	Script de integracao de arquivos entre FS do P2K e a Tesouraria
#	Autor: Agapito Rojas (agapito.rojas@lasa.com.br)
#
#	Versao 1.0 (25/04/2018)
#
####################################################################################################

BASE=`basename $0` ## Nome do script
DIRBKP="/RSYNC/ARCHIVE/TESOURARIA" ## Diretorio de backup
DIRFS="/RSYNC/P2K/EP" ## NFS para o LXLASAFS01
DIRTES="/RSYNC/IBMFARM01/TESOURARIA" ## NFS para o IBMFARM01
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Log com base no nome do script
PIDFILE="/DSOP/DLOG/${BASE%%.*}.pid" ## Arquivo de PID

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

if [ "`mount |grep ${DIRFS} |wc -l`" -eq "0" ]; then
	echo "`date \"+%F %T\"` - NFS do FS desmontado." >>${LOG} 2>&1
	exit 1
fi

if [ "`mount |grep ${DIRTES} |wc -l`" -eq "0" ]; then
	echo "`date \"+%F %T\"` - NFS da Tesouraria desmontado." >>${LOG} 2>&1
	exit 2
fi

[ ! -d ${DIRBKP} ] && mkdir -p ${DIRBKP} >/dev/null 2>&1

verifica_pid

echo "`date \"+%F %T\"` - Inicio\n" >>${LOG} 2>&1

for DIRLJ in `ls -d ${DIRFS}/LJ????`; do
	LJ=${DIRLJ#*LJ}
	if [ "`find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) 2>/dev/null |wc -l`" -gt "0" ]; then
		echo "`date \"+%F %T\"` - LOJA ${LJ}\n" >>${LOG} 2>&1
		find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) -exec rsync -cgopq --timeout=30 {} ${DIRBKP} \; >>${LOG} 2>&1 && \
		find ${DIRLJ}/Exportacao/* -prune -type f \( -name lfin* -o -name lout* -o -name lrin* -o -name LVDEP* -o -name tes* \) -exec rsync -cgopv --remove-source-files --timeout=30 {} ${DIRTES} \; >>${LOG} 2>&1
		echo >>${LOG}
	fi
done

echo "`date \"+%F %T\"` - Fim\n" >>${LOG} 2>&1
rm -f ${PIDFILE}
##Fim do script##rsync_registrado_p2k.log