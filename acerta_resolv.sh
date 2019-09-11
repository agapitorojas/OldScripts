#!/bin/bash
#
DATA=$(date +%Y%m%d)
HASHOK="ec2242fcf506b4e4465cbd79bd880401"
MD5PDV=$(md5sum /etc/resolv.conf |cut -d' ' -f1)

if [ "${HASHOK}" == "${MD5PDV}" ]; then
	echo "Arquivo resolv.conf OK."
	exit 0
else
	cp /etc/resolv.conf /etc/resolv.conf.bkp.${DATA} && \
	echo -e "nameserver 10.114.241.29 ## 054\nnameserver 10.23.93.69   ## UOL\nnameserver 10.23.87.5    ## IBM\nsearch lasa.lojasamericanas.com.br" >/etc/resolv.conf
	if [ "$?" -eq "0" ]; then
		MD5NEW=$(md5sum /etc/resolv.conf |cut -d' ' -f1)
		if [ "${HASHOK}" == "${MD5NEW}" ]; then
			echo "Arquivo resolv.conf alterado com sucesso."
			exit 0
		else
			echo "Arquivo diferente do esperado."
			exit 1
		fi
	else
		echo "Erro na alteração do arquivo."
		exit 2
	fi	
fi	