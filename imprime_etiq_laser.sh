#!/usr/bin/env bash
<<HEAD
    SCRIPT:
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script de impressão de etiquetas na impressora laser
    VERSION: 1.0 (16/08/2019)
    HISTORY:
HEAD

base=$(basename $0)
log="/DSOP/DLOG/${base%%.*}.log"
pid="/var/run/${base%%.*}.pid"

print_laser(){
    dir=$1
    etq="/P2K/EP/${dir}/Etiquetagem"
    loja=${dir#LJ}
    log_loja="/DSOP/DLOG/${base%%.*}.${loja}.log"
    echo "$(date '+%F %T') - LOJA ${loja}" >>${log} 2>&1
    for pdfs in $(find ${etq} -maxdepth 1 -type f -name 'GONDOLA_LASER?\.????????\.??????\.pdf' -printf '%f\n'); do
        if [[ -n ${pdfs} ]]; then
            for pdf in ${pdfs}; do
                printer="$(echo ${pdf} |awk -F'[_.]' '{print $2}' |tr '[:upper:]' '[:lower:]')_${loja}"
                lpr -P ${printer} ${etq}/${pdf} >>${log_loja} 2>&1
                if [[ "$?" -eq "0" ]]; then
                    mv -f ${etq}/${pdf} /P2K/P2K_CTRL/Etiquetagem/${dir} && \
                    echo "$(date '+%F %T') - ${pdf} ${printer}" >>${log_loja} 2>&1 || \
                    echo "$(date '+%F %T') - Erro ao mover o arquivo ${pdf}." >>${log_loja} 2>&1
                else
                    echo "$(date '+%F %T') - Erro ao imprimir ${pdf}." >>${log_loja} 2>&1
                fi
            done
        fi
    done
}

verifica_pid() {
	if [ -s ${pid} ]; then
		ultimo_pid=$(cat ${pid})
		if [ -d /proc/${ultimo_pid} ]; then
			echo "$(date '+%F %T') - Processo em execucao." >>${log} 2>&1
			exit 0
		else
			echo $$ >${pid}
		fi
	else
		echo $$ >${pid}
	fi
}

verifica_pid

echo "$(date '+%F %T') - Inicio." >>${log} 2>&1

for dir_lj in $(find /P2K/EP/ -maxdepth 1 -type d -name LJ[0-9][0-9][0-9][0-9] -printf '%f\n' |sort -n); do
    print_laser ${dir_lj}
done

echo "$(date '+%F %T') - Fim." >>${log} 2>&1

rm -f ${pid}