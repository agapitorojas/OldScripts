#!/bin/ksh
####################################################################################################
#
#	Script de HOMOLOGACAO da coleta de arquivos LVDA e entrega no NAS.
#	Autor: Agapito Rojas (agapito.rojas@lasa.com.br)
#
#	Versao 0.1 (30/01/2016)
#
####################################################################################################
DIRFS="/RSYNC/P2K/EP"
DIRNAS=""

set -A DIRLJ `find ${DIRFS}/* -prune -type d -name "LJ????"`

echo ${DIRLJ[@]}