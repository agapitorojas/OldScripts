#!/bin/ksh
####################################################################################################
#
#	Script de HOMOLOGAÇÃO da integração de arquivos entre Tesouraria (IBM) e MIDAS (AWS)
#	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
#
#	Versão 1.0 (12/06/2016)
#	Versão 1.1 (30/06/2016)
#		- Incluídos diretórios:
#			/RSYNC/ARQUIVOS/MIDAS/APROCESSAR
#			/RSYNC/ARQUIVOS/MIDAS/BKP
#			/RSYNC/ARQUIVOS/MIDAS/LOG
#		- Incluídos arquivos:
#			/RSYNC/ARQUIVOS/scripts/LOJAS_MIDAS
#			/RSYNC/ARQUIVOS/MIDAS/LOG/SHA1_MIDAS.log
#		- Incluída verificação de hash SHA-1 dos arquivos
#
####################################################################################################
BASE=`basename $0` ## Nome do script
DIRBKP="/RSYNC/ARQUIVOS/MIDAS/BKP"
DIRMIDAS="/var/tesouraria/files" ## Diretório remoto do Midas
DIRPROC="/RSYNC/ARQUIVOS/MIDAS/APROCESSAR" ## Diretório local de arquivos a serem enviados
DIRTESOUR="/RSYNC/TESOURARIA" ## Diretório local de arquivos de tesouraria
LISTA="/RSYNC/ARQUIVOS/scripts/LOJAS_MIDAS" ## Lista de lojas que terão os arquivos transmitidos
LOG="/RSYNC/ARQUIVOS/MIDAS/LOG/${BASE%%.*}.log" ## Log de execução
SHA1LOG="/RSYNC/ARQUIVOS/MIDAS/LOG/SHA1_MIDAS.log" ## Log de controle com o hash SHA-1 dos arquivos
SRVMIDAS="10.224.28.131" ## IP do servidor de HOMOLOGAÇÃO do Midas
USRMIDAS="midas" ## Usuário remoto de HOMOLOGAÇÃO do Midas

echo "`date \"+%F - %T\"` - Início\n" >>${LOG} 2>&1

for LOJA in `cat ${LISTA}`; do
	for FILE in `find ${DIRTESOUR}/* -prune -type f -name "*.${LOJA}" -a \( -name "lfin*" -o -name "lout*" -o -name "lrin*" -o -name "LVDEP*" -o -name "tes*" \) 2>/dev/null`; do
		SHA1=`/usr/bin/csum -h SHA1 ${FILE} 2>/dev/null |awk '{print $1}'`
		SHA1CTRL=`grep -w ${FILE}$ ${SHA1LOG} 2>/dev/null |awk '{print $1}'`
		if [ "${SHA1}" != "${SHA1CTRL}" ]; then
			cp ${FILE} ${DIRPROC} >>${LOG} 2>&1
			EXIT=$?
			if [ "${ERRO}" -eq "0" ]; then
				echo "Arquivo \"${FILE}\" copiado para APROCESSAR" >>${LOG} 2>&1
				echo "${SHA1} ${FILE}" >>${SHA1LOG}
			else
				echo "Erro ao copiar arquivo ${FILE}"
			fi
		fi
	done	
done
if [ `find ${DIRPROC}/* -prune -type f \( -name 'lfin*' -o -name 'lout*' -o -name 'lrin*' -o -name 'LVDEP*' -o -name 'tes*' \) 2>/dev/null |wc -l` -gt 0 ]; then
	echo "`date \"+%F - %T\"` - Transmitindo arquivos para o Midas\n" >>${LOG} 2>&1
	rsync -cgnopv --progress --remove-source-files --timeout=20 ${DIRPROC}/* ${USRMIDAS}@${SRVMIDAS}:${DIRMIDAS}/filewatcher/current >>${LOG} 2>&1 ## Dry run
	EXIT=$?
	if [ "${EXIT}" -eq "0" ]; then
		echo "`date \"+%F - %T\"` - Arquivos transmitidos para o Midas com sucesso" >>${LOG} 2>&1
	else
		echo "`date \"+%F - %T\"` - Erro ${EXIT} ao transmitir arquivos"
	fi
fi
echo "`date \"+%F - %T\"` - Fim\n" >>${LOG} 2>&1
#	Fim do script