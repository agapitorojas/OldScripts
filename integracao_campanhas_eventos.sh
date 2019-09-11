#!/bin/bash
:"
  Novo script de integração de Regras de Descontos, Campanhas e Eventos com lojas Prisma.

  Autor: Agápito Rojas (agapito.rojas@lasa.com.br)

  Versão 1.0 (24/10/2016)
  Versão 1.1 (01/11/2016)
  	- Remoção da saída (exit) do teste do mínimo de arquivos
  Versão 1.2 (08/11/2016)
  	- Alterada origem dos arquivos de Fidelização
  Versão 1.3 (14/11/2016)
  	- Incluído descarte de arquivos antigos na função 'distribui_por_loja'
"
SCRIPT=$(basename $0)
HOST=$(hostname)
LOG=/DSOP/DLOG/${SCRIPT%.*}.log
EXPORT="/P2K/EP/LJ0000/Exportacao"
STATX="/lasa/usr/PRODUCAO/COMNC/STATX"
RSYNC="rsync -av --progress --remove-source-files"

timestamp(){
	date +%Y%m%d%H%M%S
}

data_hora(){
	date '+%F %T'
}

saida(){
	echo $?
}

coleta_arquivos(){
	mkdir -p ${DESTINO}/{BACKUP,TRAB}
	cd ${ORIGEM}
	if [ $(ls -l ${ARQUIVOS} |wc -l) -ge ${MINCOLETA} ]; then ### Testa se há o mínimo de arquivos.
		if [ $(ls -l ${CONTROLE} |wc -l) -eq 1 ]; then ### Testa se há apenas 1 arquivo de controle.
			echo -e "$(data_hora) ${HOST} - Coletando arquivos:\n" >>${LOGPROC} 2>&1
			${RSYNC} ${ARQUIVOS} ${DESTINO} >>${LOGPROC} 2>&1 ### Executa rsync removendo a origem.
			if [ $(saida) -eq 0 ]; then
				echo -e "\n$(data_hora) ${HOST} - Arquivos movidos com sucesso." >>${LOGPROC} 2>&1
				chmod 766 ${DESTINO}/*.txt
			else
				echo -e "$(data_hora) ${HOST} - Erro $(saida) no transporte dos arquivos." >>${LOGPROC} 2>&1
				exit 4
			fi
		else
			echo -e "$(data_hora) ${HOST} - Mais de um arquivo de controle encontrado." >>${LOGPROC} 2>&1
			exit 3
		fi
	else
		echo -e "$(data_hora) ${HOST} - Sem o mínimo de arquivos na origem." >>${LOGPROC} 2>&1
		exit 2
	fi
}

cria_arquivos_por_grupo(){
	echo -e "$(data_hora) ${HOST} - Criando arquivos por grupo:" >>${LOGPROC} 2>&1
	cd ${DESTINO}
	for GRUPO in $(cat ${CONTROLE} |cut -c1-4 |sort -n |uniq); do
		if [ $(ls -l *${GRUPO}.*.txt |wc -l) -eq ${MINGRUPO} ]; then ### Testa se há o mínimo de arquivos por grupo.
			ARQPROC="${TRAB}/${PROCESSO}.${GRUPO}.$(timestamp).tbz2"
			tar cjf ${ARQPROC} *${GRUPO}.*.txt ### Cria um tarball por grupo.
			if [ $(saida) -eq 0 ]; then
				echo -e "$(data_hora) ${HOST} - Arquivo ${ARQPROC} criado." >>${LOGPROC} 2>&1
				chmod 766 ${ARQPROC}
			else
				echo -e "$(data_hora) ${HOST} - Erro na criação do arquivo ${ARQPROC}." >>${LOGPROC} 2>&1
				exit 5
			fi
		else
			echo -e "$(data_hora) ${HOST} - Sem o mínimo de arquivos para o grupo ${GRUPO}." >>${LOGPROC} 2>&1
		fi
	done	
}

distribui_por_loja(){
	echo -e "$(data_hora) ${HOST} - Copiando arquivos para diretórios de lojas:\n" >>${LOGPROC} 2>&1
	ERRO="0" ### Variável para sáida de erro do "cp".
	for LINHA in $(cat ${CONTROLE}); do
		GRPLJ=$(echo ${LINHA} |cut -c1-4)
		LOJA=$(echo ${LINHA} |cut -c5-8)
		if [ ! -d ${DESTINO}/LJ${LOJA} ]; then
			mkdir -p ${DESTINO}/LJ${LOJA}
		fi
		if ls ${DESTINO}/LJ${LOJA}/${PROCESSO}.*.tbz2 >/dev/null 2>&1; then
			echo -e "Removendo arquivos antigos LOJA ${LOJA}" >>${LOGPROC} 2>&1
			rm -fv ${DESTINO}/LJ${LOJA}/${PROCESSO}.*.tbz2 >>${LOGPROC} 2>&1
		fi
		echo -e "LOJA ${LOJA} GRUPO ${GRPLJ}" >>${LOGPROC} 2>&1
		cp -v ${TRAB}/${PROCESSO}.${GRPLJ}.*.tbz2 ${DESTINO}/LJ${LOJA} >>${LOGPROC} 2>&1 ### Copia para diretório da loja o arquivo do seu grupo.
		[ $(saida) -ne 0 ] && ERRO="1" ### Em caso de erro, altera a variável.
	done
	if [ ${ERRO} -eq 0 ]; then
		echo -e "\n$(data_hora) ${HOST} - Arquivos copiados com sucesso." >>${LOGPROC} 2>&1
	else
		echo -e "\n$(data_hora) ${HOST} - Arquivos copiados com algum erro. Veja o log." >>${LOGPROC} 2>&1
	fi
	chown -R rsync ${DESTINO}
}

faz_backup(){
	echo -e "$(data_hora) ${HOST} - Movendo arquivos para backup:\n" >>${LOGPROC} 2>&1
	mv -v ${DESTINO}/*.txt ${BACKUP} >>${LOGPROC} 2>&1
	mv -v $TRAB/*.tbz2 ${BACKUP} >>${LOGPROC} 2>&1
}

if [ "$#" -ne 1 ]; then
	echo "Utilização: ${SCRIPT} {fidelizacao|campanhas|eventos|cuponagem}"
	exit 1
fi

PARAM="$1"
PROCESSO=$(echo "${PARAM}" |tr '[:lower:]' '[:upper:]')
DESTINO="${STATX}/${PROCESSO}"
BACKUP="${DESTINO}/BACKUP"
TRAB="${DESTINO}/TRAB"
LOGPROC="/DSOP/DLOG/${SCRIPT%.*}.${PROCESSO}.log"

case ${PROCESSO} in

	CAMPANHA)

	ORIGEM="${EXPORT}"
	ARQUIVOS="brindes.*.txt
	campgrplj.*.txt
	levpag.*.txt"
	ARQGRUPO="brindes
	levpag"
	CONTROLE="campgrplj.*.txt"
	MINCOLETA="3"
	MINGRUPO="2"

	echo -e "$(data_hora) ${HOST} - Início:" >>${LOGPROC} 2>&1
	coleta_arquivos
	cria_arquivos_por_grupo
	distribui_por_loja
	faz_backup
	echo -e "\n$(data_hora) ${HOST} - Fim." >>${LOGPROC} 2>&1
	;;

	EVENTO)

	ORIGEM="${EXPORT}"
	ARQUIVOS="plevgrplj.*.txt
	TDPIT.*.txt
	TEVCARTAO.*.txt
	TEVDEPIT.*.txt
	TEVDESC.*.txt
	TEVGERAL.*.txt"
	ARQGRUPO="TDPIT
	TEVCARTAO
	TEVDEPIT
	TEVDESC
	TEVGERAL"
	CONTROLE="plevgrplj.*.txt"
	MINCOLETA="6"
	MINGRUPO="5"

	echo -e "$(data_hora) ${HOST} - Início:" >>${LOGPROC} 2>&1
	coleta_arquivos
	cria_arquivos_por_grupo
	distribui_por_loja
	faz_backup
	echo -e "\n$(data_hora) ${HOST} - Fim." >>${LOGPROC} 2>&1
	;;

	FIDELIZACAO)

	ORIGEM="${EXPORT}"
	ARQUIVOS="rddet.*.txt
	rdgrplj.*.txt
	regras.*.txt"
	ARQGRUPO="rddet
	regras"
	CONTROLE="rdgrplj.*.txt"
	MINCOLETA="3"
	MINGRUPO="2"

	echo -e "$(data_hora) ${HOST} - Início:" >>${LOGPROC} 2>&1
	coleta_arquivos
	cria_arquivos_por_grupo
	distribui_por_loja
	faz_backup
	echo -e "\n$(data_hora) ${HOST} - Fim." >>${LOGPROC} 2>&1
	;;

	*) echo "Utilização: ${SCRIPT} {fidelizacao|campanhas|eventos|cuponagem}"
	exit 1
	;;
esac