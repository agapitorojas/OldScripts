#!/bin/bash
#
IP=$(hostname -i)
KERNEL=$(uname -r |cut -d. -f1-2)
LOJA=$(hostname |cut -c6-)
[ ${LOJA} -lt 1000 ] && LOJA="0${LOJA}"
EPSRV="52.31.153.148"
FSP2K="52.31.153.178"
SPSRV="${IP}"
SP=$(grep -i spserver /etc/hosts |awk '{print $1}')
EP=$(grep -i epserver /etc/hosts |awk '{print $1}')

if [[ "${KERNEL}" != "2.6" ]]; then
   echo "Kernel antigo!"
   exit 1
fi

if [ -e /DSOP/DTAB/EH_P2K_TOTAL -o -e /DSOP/DTAB/EH_P2K_HIBRIDA ]; then
	echo "Loja já é P2K."
	exit 2
fi

id p2ksp >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
	echo "Criando usuário p2ksp."
	groupadd p2ksp -g 1012 && adduser p2ksp -u 1012 -g 1012
	if [[ $? -ne 0 ]]; then
		echo "Erro na criação do usuário."
	fi
fi

echo "Alterando senha do p2ksp."
echo "#lasa2011" |passwd --stdin p2ksp
if [[ $? -ne 0 ]]; then
	echo "Erro na alteração da senha."
fi

if [ -e /lasa/PACOTES/p2ksp.tbz ]; then
	echo "Matando processos do '/p2ksp'."
	kill -9 $(lsof -t /p2ksp) 2>/dev/null
	cd /p2ksp
	if [[ $(pwd) == "/p2ksp" ]]; then
		echo "Limpando diretório '/p2ksp'."
		rm -fr *
		if [[ $? -eq 0 ]]; then
			echo "Descompactando pacote p2ksp novo."
			tar xjf /lasa/PACOTES/p2ksp.tbz
			if [[ $? -eq 0 ]]; then
				mv sp_ljXXXX sp_lj${LOJA}
				if [[ $? -eq 0 ]]; then
					chown -R p2ksp:p2ksp /p2ksp
					ln -s /p2ksp /usr/p2ksp
					echo "Pacote p2ksp atualizado."
				else
					echo "Erro ao renomear o diretório sp_lj????."
				fi
			else
				echo "Erro ao descompactar o pacote p2ksp."
			fi
		else
			echo "Erro ao limpar o diretório '/p2ksp'."
		fi
	else
		echo "Diretório '/p2ksp' não encontrado."
	fi
else
	echo "Pacote p2ksp novo não encontrado."
fi

if [[ "${IP}" != "${SP}" ]]; then
	echo -e "${SPSRV}\tSPSERVER spServer SPserver spSERVER" >>/etc/hosts
fi

if [[ "${EP}" != "${EPSRV}" ]]; then
	echo -e "${EPSRV}\tEPSERVER epServer EPserver epSERVER"	>>/etc/hosts
fi

if [ -e /lasa/PACOTES/initp2k.tar.bz2 ]; then
	cd /etc/init.d
	if [[ $(pwd) == "/etc/init.d" ]]; then
		tar xjf /lasa/PACOTES/initp2k.tar.bz2
		if [[ $? -ne 0 ]]; then
			echo "Erro na descompressão dos scripts init."
		fi
	fi
else
	echo "Arquivo initp2k.tar.bz2 não encontrado."
fi

if [ -e /lasa/PACOTES/rc5.d.tbz ]; then
	cd /etc/rc5.d
	if [[ $(pwd) == "/etc/rc5.d" ]]; then
		tar xjf /lasa/PACOTES/rc5.d.tbz
		if [[ $? -ne 0 ]]; then
			echo "Erro na descompressão dos links rc5."
		fi
	fi
else
	echo "Arquivo rc5.d.tbz não encontrado."
fi

chmod 555 /DSOP/DEXE/pup2kintegracao001

echo 1 >/DSOP/DTAB/EH_P2K_HIBRIDA

echo FIM