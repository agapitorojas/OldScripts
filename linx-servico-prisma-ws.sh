#!/bin/bash
#
# linx-servico-prisma-ws	Inicia o serviço Prisma WS
#
# chkconfig: 2345 20 80
# description: Script de System V init para o Serviço Prisma WS
PIDFILE="/var/run/linx-servico-prisma-ws.pid"

. /etc/init.d/functions

checkpid (){
	if [ -s ${PIDFILE} ]; then
		LASTPID=$(cat ${PIDFILE})
		if [ -n ${LASTPID} -a -d /proc/${LASTPID} ]; then
			return 1
		else
			rm -f ${PIDFILE}
			return 0
		fi
	elif [ "$(pgrep -f linx.prisma.ServicoPrismaWS |wc -l)" -eq "1" ]; then
		pgrep -f linx.prisma.ServicoPrismaWS >${PIDFILE}
		return 1
	elif [ "$(pgrep -f linx.prisma.ServicoPrismaWS |wc -l)" -gt "1" ]; then
		return 2
	else
		return 0
	fi
}

start (){
	if [ -x /lasa/pdvs/dados/linx-servico-prisma-ws/bin/exec-servico.sh ]; then
		checkpid
		CHECK=$?
		if [ ${CHECK} -eq 0 ]; then
			cd /lasa/pdvs/dados/linx-servico-prisma-ws/bin
			sh exec-servico.sh >/dev/null 2>&1 &
			RET=$?
			if [ ${RET} -eq 0 ]; then
				PID=$(pgrep -f linx.prisma.ServicoPrismaWS |tail -1)
				if [ -n ${PID} ]; then
					echo ${PID} >${PIDFILE}
					echo OK
				else
					echo ERRO
					exit 3
				fi
			else
				echo ERRO
				exit 2
			fi
		else
			echo "Serviço em execução"
			exit 0
		fi
	else
		echo "Script não encontrado"
		exit 1
	fi
}

stop (){
	checkpid
	CHECK=$?
	if [ "${CHECK}" -gt 0 ]; then
		kill -9 $(pgrep -f 'exec-servico.sh|linx.prisma.ServicoPrismaWS') >/dev/null 2>&1
		sleep 2
		checkpid
		CHECK=$?
		if [ ${CHECK} -eq 0 ]; then
			echo OK
		else
			echo ERRO
			exit 1
		fi
	else
		echo OK
	fi
}

restart (){
	stop
	start
}

status (){
	checkpid
	CHECK=$?
	if [ ${CHECK} -eq 1 ]; then
		echo "Serviço em execução"
	elif [ ${CHECK} -eq 2 ]; then
		echo "Mais de um processo em execução"
	elif [ ${CHECK} -eq 0 ]; then
		echo "Serviço parado"
	fi
}

case $1 in
	start) start;;
	stop) stop;;
	restart) restart;;
	status) status;;
	*) echo "Uso: linx-servico-prisma-ws {start|stop|restart|status}";;
esac