#!/bin/bash
:"
	Script de download dos arquivos de Planos e Eventos nas lojas Prisma.

	Autor: Agápito Rojas (agapito.rojas@lasa.com.br)

	Versão 1.0 (27/10/2016)
"
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1
SCRIPT=$(basename $0)
LOG="/DSOP/DLOG/${SCRIPT%.*}.log"
HOST=$(hostname)
LOJA=$(hostname |cut -c6-)
[ ${LOJA} -lt 1000 ] && LOJA=0${LOJA}
SERVER=$(cat /DSOP/DTAB/servidor_arquivos_p2k)
DIR_REMOTO="/lasa/usr/PRODUCAO/COMNC/STATX/EVENTO/LJ${LOJA}"
DIR_LOCAL="/lasa/usr/COMNC/STARX"
SSH="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
RSYNC="rsync -vgop --progress --remove-source-files --bwlimit=32 --timeout=30"
TEMPO="$(echo "$RANDOM % 61" |bc)"

data_hora(){
	date '+%F %T'
}

executa_cobol(){
	export COBSW=-F
    export COBDIR=/opt/microfocus/cobol/
    export LIBPATH=$COBDIR/lib:$LIBPATH:/usr/lib
    cd $CONCENTRADOR
    ./exec/sup01285
    ./exec/sup01290
}

mkdir -p ${DIR_LOCAL}/EVENTO/{BACKUP,TRAB}
echo -e "$(data_hora) ${HOST} - Início" >>${LOG} 2>&1
echo -e "$(data_hora) ${HOST} - Download do arquivo:" >>${LOG} 2>&1
SUCESSO="0"
for TRY in $(seq 5); do
	echo -e "$(data_hora) ${HOST} - Tentativa ${TRY}:\n" >>${LOG} 2>&1
	sleep ${TEMPO}
	${RSYNC} --rsh="${SSH}" ${SERVER}:${DIR_REMOTO}/EVENTO.????.??????????????.tbz2 ${DIR_LOCAL}/EVENTO/TRAB >>${LOG} 2>&1
	EXIT=$?
	if [ ${EXIT} -eq 0 ]; then
		SUCESSO="1"
		echo -e "\n$(data_hora) ${HOST} - Download executado com sucesso." >>${LOG} 2>&1
		break
	elif [ ${EXIT} -eq 23 ]; then
		echo -e "$(data_hora) ${HOST} - Sem arquivo para download." >>${LOG} 2>&1
		break
	elif [ ${TRY} -eq 5 ]; then
		echo -e "$(data_hora) ${HOST} - Erro ${EXIT} no download." >>${LOG} 2>&1
	fi
done

if [ ${SUCESSO} -eq 1 ]; then
	cd ${DIR_LOCAL}/EVENTO/TRAB
	rm -fv TDPIT.*.txt TEVCARTAO.*.txt TEVDEPIT.*.txt TEVDESC.*.txt TEVGERAL.*.txt >>${LOG} 2>&1
	echo -e "$(data_hora) ${HOST} - Descompactando arquivos." >>${LOG} 2>&1
	tar xjf EVENTO.*.*.tbz2
	EXIT=$?
	if [ ${EXIT} -eq 0 ]; then
		echo -e "$(data_hora) ${HOST} - Testando arquivos." >>${LOG} 2>&1
		MD5NOVO=$(md5sum TDPIT.*.txt TEVCARTAO.*.txt TEVDEPIT.*.txt TEVDESC.*.txt TEVGERAL.*.txt 2>/dev/null |awk '{print $1}' |md5sum 2>/dev/null |awk '{print $1}')
		MD5ATUAL=$(md5sum ${DIR_LOCAL}/TDPIT.txt ${DIR_LOCAL}/TEVCARTAO.txt ${DIR_LOCAL}/TEVDEPIT.txt ${DIR_LOCAL}/TEVDESC.txt ${DIR_LOCAL}/TEVGERAL.txt 2>/dev/null |awk '{print $1}' |md5sum 2>/dev/null |awk '{print $1}')
		if [ ${MD5NOVO} != ${MD5ATUAL} ]; then
			echo -e "$(data_hora) ${HOST} - Atualizando arquivos:" >>${LOG} 2>&1
			rm -fv ${DIR_LOCAL}/TDPIT.txt ${DIR_LOCAL}/TEVCARTAO.txt ${DIR_LOCAL}/TEVDEPIT.txt ${DIR_LOCAL}/TEVDESC.txt ${DIR_LOCAL}/TEVGERAL.txt >>${LOG} 2>&1
			mv -fv TDPIT.*.txt ${DIR_LOCAL}/TDPIT.txt >>${LOG} 2>&1
			mv -fv TEVCARTAO.*.txt ${DIR_LOCAL}/TEVCARTAO.txt >>${LOG} 2>&1
			mv -fv TEVDEPIT.*.txt ${DIR_LOCAL}/TEVDEPIT.txt >>${LOG} 2>&1
			mv -fv TEVDESC.*.txt ${DIR_LOCAL}/TEVDESC.txt >>${LOG} 2>&1
			mv -fv TEVGERAL.*.txt ${DIR_LOCAL}/TEVGERAL.txt >>${LOG} 2>&1
			echo -e "$(data_hora) ${HOST} - Executando COBOL:" >>${LOG} 2>&1
			executa_cobol >>${LOG} 2>&1
			EXIT=$?
			if [ ${EXIT} -eq 0 ]; then
				echo -e "$(data_hora) ${HOST} - COBOL executado com sucesso." >>${LOG} 2>&1
			else
				echo -e "$(data_hora) ${HOST} - Erro ${EXIT} na execução do COBOL." >>${LOG} 2>&1
			fi
		else
			echo -e "$(data_hora) ${HOST} - Arquivos não alterados." >>${LOG} 2>&1
			rm -fv TDPIT.*.txt TEVCARTAO.*.txt TEVDEPIT.*.txt TEVDESC.*.txt TEVGERAL.*.txt >>${LOG} 2>&1
		fi
	else
		echo -e "$(data_hora) ${HOST} - Erro na descompactaçao dos arquivos." >>${LOG} 2>&1
	fi
	echo -e "$(data_hora) ${HOST} - Movendo arquivos para o backup." >>${LOG} 2>&1
	mv -fv ${DIR_LOCAL}/EVENTO/TRAB/EVENTO.*.*.tbz2 ${DIR_LOCAL}/EVENTO/BACKUP >>${LOG} 2>&1
fi
echo -e "$(data_hora) ${HOST} - Fim" >>${LOG} 2>&1