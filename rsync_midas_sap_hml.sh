#!/bin/ksh
####################################################################################################
#
#	Script de HOMOLOGAÇÃO da integração de arquivos entre MIDAS (AWS) e SAP (IBM)
#	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
#
#	Versão 1.0 (06/07/2016)
#
####################################################################################################
BASE=`basename $0` ## Nome do script
DIRMIDAS="/var/tesouraria/files" ## Diretório remoto do Midas
DIRBC="${DIRMIDAS}/BC" ## Diretório remoto de arquivos BC
DIRDB="${DIRMIDAS}/DB" ## Diretório remoto de arquivos DB
DIRFI="${DIRMIDAS}/FI" ## Diretório remoto de arquivos FI
DIRRX="/lasa/usr/PRODUCAO/COMNC/STARX" ## Diretório local de arquivos recebidos
DIRSAP="/lasa/usr/PRODUCAO/ARQ/SAP/LIBSAP" ## Diretório local de arquivos para processar
LOG="/tesouraria_new/logs/${BASE%%.*}.log" ## Log de execução
SRVMIDAS="10.224.28.131" ## IP do servidor de HOMOLOGAÇÃO do Midas
USRMIDAS="midas" ## Usuário remoto de HOMOLOGAÇÃO do Midas

echo "`date \"+%F - %T\"`: Início" >>${LOG} 2>&1

function colect {
	TYPE=$1
	case ${TYPE} in
		BC) DIR=${DIRBC};;
		DB) DIR=${DIRDB};;
		FI) DIR=${DIRFI};;
		*) echo "`date \"+%F - %T\"`: Tipo errado" >>${LOG} 2>&1
		exit 1;;
	esac
	[ ! -d "$DIRRX/${TYPE}" ] && mkdir -p ${DIRRX}/${TYPE}
	LIST="`ssh -o ConnectTimeout=10 ${USRMIDAS}@${SRVMIDAS} \"ls ${DIR}/${TYPE}??????.???? 2>/dev/null |wc -l\"`"
	EXIT=$?
	if [ "${LIST}" -gt "0" ]; then
		echo "`date \"+%F - %T\"`: Coletando arquivos ${TYPE}" >>${LOG} 2>&1
##		rsync -acnv --remove-source-files --timeout=10 ${USRMIDAS}@${SRVMIDAS}:${DIR}/${TYPE}??????.???? ${DIRSAP} >>${LOG} 2>&1 ## Dry run preservando mtime
		rsync -cgnopv --remove-source-files --timeout=10 ${USRMIDAS}@${SRVMIDAS}:${DIR}/${TYPE}??????.???? ${DIRRX}/${TYPE} >>${LOG} 2>&1 ## Dry run sem mtime
		EXIT=$?
		if [ "${EXIT}" -eq "0" ]; then
			echo "`date \"+%F - %T\"`: Arquivos ${TYPE} coletados com sucesso" >>${LOG} 2>&1
			echo "`date \"+%F - %T\"`: Renomeando arquivos" >>${LOG} 2>&1
			cd ${DIRRX}/${TYPE}
			if [ "`pwd`" == "${DIRRX}/${TYPE}" ]; then
				for OLD in `ls ${TYPE}??????.????`; do
					NEW="${OLD}.`date +%Y%m%d`.`date +%H%M%S`"
					mv ${OLD} ${DIRSAP}/${NEW}
					EXIT=$?
					if [ "${EXIT}" -eq "0" ]; then
						echo "${OLD} -> ${NEW}" >>${LOG} 2>&1
					else
						echo "`date \"+%F - %T\"`: Erro ao renomear arquivo ${OLD}" >>${LOG} 2>&1
					fi
				done
				if [ "${EXIT}" -eq "0" ]; then
					echo "`date \"+%F - %T\"`: Arquivos ${TYPE} movidos com sucesso" >>${LOG} 2>&1
				fi
			fi
		else
			echo "`date \"+%F - %T\"`: Erro ${EXIT} no rsync" >>${LOG} 2>&1
		fi
	elif [ "${EXIT}" -ne "0" ]; then
		echo "`date \"+%F - %T\"`: Erro ${EXIT} ao acessar servidor remoto" >>${LOG} 2>&1
	else 
		echo "`date \"+%F - %T\"`: Sem arquivos ${TYPE}" >>${LOG} 2>&1
	fi
}

colect BC
colect DB
colect FI

echo "`date \"+%F - %T\"`: Fim" >>${LOG} 2>&1
## Fim do Script