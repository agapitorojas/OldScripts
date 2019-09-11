#!/bin/bash
DATA=$(date +%Y%m%d)
LOJA=$(hostname |cut -d_ -f2)
[ ${LOJA} -lt 1000 ] && LOJA=0${LOJA}
RPAR="-vogp --progress"
SPAR="-q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

versao_java(){
	/p2ksp/jre/bin/java -version
}

troca_jre(){
	cd /p2ksp
	mv -fv jre jre.${DATA}
	tar xjvf /tmp/java_1.7.0_09.tar.bz2
	/etc/init.d/iniciaSP start
}

echo "Versão atual do Java:"
versao_java

echo "Baixando versão nova do Java."
su rsync -c "rsync ${RPAR} --rsh='ssh ${SPAR}' lxlasa11:/lasa/PACOTES/java_1.7.0_09.tar.bz2 /tmp"

if [ $? -eq 0 ]; then
	echo -e "\nJava baixado com sucesso.\n"
	echo "Parando o p2ksp."
	killall -s9 -up2ksp
	if [ $(pgrep -up2ksp |wc -l) -eq 0 ]; then
		troca_jre	
	else
		for PID in $(ps aux |grep ^p2ksp |awk '{print $2}'); do
			kill -9 ${PID}
		done
		troca_jre
	fi
fi
echo "Versão final do Java:"
versao_java