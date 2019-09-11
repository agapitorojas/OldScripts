#!/bin/ksh
####################################################################################################
#
#	Script de integracao de arquivos entre Tesouraria (IBM) e MIDAS (AWS)
#	Autor: Agapito Rojas (agapito.rojas@lasa.com.br)
#
#	Versao 1.0 (08/02/2018)
#	Versao 1.1 (15/02/2018)
#		- Melhorada saida de log
#		- Alterado algoritimo de SHA1 para MD5
#	Versao 1.2 (16/02/2018)
#		- Incluida verificacao de processo em execucao
#	Versao 1.3 (26/12/2018)
#		- Incluido timestamp no arquivo de hashes
#
####################################################################################################
BASE=`basename $0` ## Nome do script
DIRCTF="/RSYNC/IBMFARM01/CTF/ctf_processados" ## NFS para IBMFARM01:/tesouraria/ctf
DIRMIDAS="/var/tesouraria/files" ## Diretorio remoto no Midas
DIRTX="/RSYNC/MIDAS/TX" ## Diretorio de transmissao
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Arquivos de log
MD5LOG="/DSOP/DLOG/${BASE%%.*}_MD5.log" ## Hash MD5 dos arquivos transmitidos
PIDFILE="/DSOP/DLOG/${BASE%%.*}.pid" ## Arquivo de PID
SRVMIDAS="10.223.2.182" ## IP do midas na AWS
USRMIDAS="ftpman" ## Usuario no Midas

function verifica_pid {
	if [ -s ${PIDFILE} ]; then
		LASTPID=`cat ${PIDFILE}`
		if [ -d /proc/${LASTPID} ]; then
			echo "`date \"+%F - %T\"` - Processo em execucao" >>${LOG} 2>&1
			exit 0
		else
			echo $$ >${PIDFILE}
		fi
	else
		echo $$ >${PIDFILE}
	fi
}

verifica_pid

echo "Início `date \"+%F - %T\"`\n" >>${LOG} 2>&1

for FILE in `find ${DIRCTF}/* -prune -type f -name "????????_????????_??????.????" 2>/dev/null`; do
	MD5=`/usr/bin/csum ${FILE} 2>/dev/null |awk '{print $1}'`
	MD5CTRL=`grep -w ${FILE} ${MD5LOG} |tail -1 2>/dev/null |awk '{print $1}'`
	if [ "${MD5}" != "${MD5CTRL}" ]; then
		cp ${FILE} ${DIRTX}
		EXIT=$?
		if [ "${ERRO}" -eq "0" ]; then
			echo "${FILE} -> ${DIRTX}/${FILE##*/}" >>${LOG} 2>&1
			echo "${MD5} ${FILE} `date \"+%F - %T\"`" >>${MD5LOG}
		else
			echo "Erro ao copiar arquivo ${FILE}"
		fi
	fi
done

if [ `find ${DIRTX}/* -prune -type f -name "????????_????????_??????.????" 2>/dev/null |wc -l` -gt 0 ]; then
	echo "\n`date \"+%F - %T\"` - Transmitindo arquivos para o Midas\n" >>${LOG} 2>&1
	rsync --remove-source-files -cgopv --timeout=30 ${DIRTX}/????????_????????_??????.???? ${USRMIDAS}@${SRVMIDAS}:${DIRMIDAS}/ctfwatcher/current >>${LOG} 2>&1
	EXIT=$?
	if [ "${EXIT}" -eq "0" ]; then
		echo "`date \"+%F - %T\"` - Arquivos transmitidos para o Midas com sucesso" >>${LOG} 2>&1
	else
		echo "`date \"+%F - %T\"` - Erro ${EXIT} ao transmitir arquivos"
	fi
else
	echo "`date \"+%F - %T\"` - Sem arquivos para transmitir" >>${LOG} 2>&1
fi
echo "\nFim `date \"+%F - %T\"`\n" >>${LOG} 2>&1
rm -f ${PIDFILE} >/dev/null 2>&1
#	Fim do script