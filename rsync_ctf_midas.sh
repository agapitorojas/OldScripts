#!/bin/ksh
####################################################################################################
#
#	Script de integração de arquivos entre Tesouraria e MIDAS
#
DIRCTF="/RSYNC/CTF/ctf_processados"
DIRMIDAS="/var/tesouraria/files"
LISTA="/RSYNC/ARQUIVOS/scripts/ARQUIVOS_MIDAS"
LOG="/RSYNC/ARQUIVOS/scripts/rsync_ctf_midas.log"
SRVMIDAS="10.223.2.182"
USRMIDAS="ftpman"

echo "Início `date \"+%F - %T\"`\n" >>${LOG} 2>&1

rsync -vcpogtzh --progress --include-from="${LISTA}" --exclude="*" ${DIRCTF}/* ${USRMIDAS}@${SRVMIDAS}:${DIRMIDAS}/ctfwatcher/current >>${LOG} 2>&1

echo "\nFim `date \"+%F - %T\"`\n" >>${LOG} 2>&1

#	Fim do script