#!/bin/ksh
####################################################################################################
#
#	Script de integração de arquivos entre Tesouraria e MIDAS
#
DIRTESOUR="/RSYNC/TESOURARIA"
DIRMIDAS="/var/tesouraria/files"
LISTA="/RSYNC/ARQUIVOS/scripts/ARQUIVOS_MIDAS"
LOG="/RSYNC/ARQUIVOS/scripts/rsync_tesour_midas.log"
SRVMIDAS="10.223.2.182"
USRMIDAS="ftpman"

echo "Início `date \"+%F - %T\"`\n" >>${LOG} 2>&1

rsync -vcpogtzh --progress --include-from="${LISTA}" --exclude="*" ${DIRTESOUR}/* ${USRMIDAS}@${SRVMIDAS}:${DIRMIDAS}/filewatcher/current >>${LOG} 2>&1

echo "\nFim `date \"+%F - %T\"`\n" >>${LOG} 2>&1

#	Fim do script