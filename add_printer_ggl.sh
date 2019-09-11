#!/bin/bash
<<HEADER
    SCRIPT: add_printer_ggl.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para adicionar impressoras laser dos GGLs
    VERSION: 1.0 (22/08/2018)
    HISTORY:
HEADER

BASE=$(basename $0) ## Nome do script
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Arquivo de log
LOJAS=$@

export PATH=/DSOP/DEXE:$PATH

if [ "$#" -lt "1" ]; then
    echo "Uso: ${BASE} [LOJA]"
    exit 1
fi

check_hosts(){
    if [ "$(grep -w $1 /etc/hosts 2>/dev/null |wc -l)" ]; then
        if [ "awk '/$1/ {print $1}'" != "$2" ]; then
             
}

printer_ip(){
    if [ "$(ver_end $1 |awk -F. '{print $1}')" -eq "10" ]; then
        ver_end $1 |awk '{print $1}' |sed 's/\.1$/\.24/g'
    elif [ "$(ver_end $1 |awk -F. '{print $1}')" -eq "52" ]; then
        ver_end $1 |awk '{print $1}' |sed 's/\.1$/\.99/g'
    fi
}

printer_type() {
    if [ "$(nmap $1 -p 80 2>/dev/null |grep open |wc -l)" -gt "0" ]; then
#       curl -m 30 -fsSI -X GET -L http://$1/ 2>/dev/null |awk '/^Connection: close|^Location: \/sws\/index\.sws|^Server: Web-Server/'
        if [ "$(curl -m 30 -fsS -X GET -L http://$1/ 2>/dev/null |awk '/href/ && /\/sws\/index\.sws/' |wc -l)" -gt "0" ]; then
            echo "SAMSUNG"
        elif [ "$(curl -m 30 -fsS -X GET -L http://$1/ 2>/dev/null |awk '/\/web\/guest\/..\/websys\/webArch\/mainFrame.cgi/' |wc -l)" -gt "0" ]; then
            echo "RICOH"
        elif [ "$(curl -m 30 -fsS -X GET -L http://$1/ 2>/dev/null |awk '/Lexmark/' |wc -l)" -gt "0" ]; then
            echo "LEXMARK"
        else
            echo "OUTRA"
        fi
    else
        echo "Impressora inacessível."
    fi
}

for LJ in $@; do
    if [ "${LJ}" -ge "0" ] 2>/dev/null; then
        LJ=$(echo ${LJ} |awk '{printf "%04d\n", $0;}')
        PPD="L${LJ}_PEGUENALOJA.ppd"
        PRINTER="L${LJ}_PEGUENALOJA"
        IPPRINT=$(printer_ip ${LJ})
#       HEAD=$(curl -m 30 -fsSI -X GET -L http://${IPPRINT} |awk '/^Content-Type: text\/html|^Location: \/sws\/index\.sws|^Server: Web-Server/')
        TYPE=$(printer_type ${IPPRINT})
        echo "LOJA ${LJ}:"
        case ${TYPE} in
            SAMSUNG)
            cp -f /etc/cups/ppd/ML4055.ppd /etc/cups/ppd/${PPD}
            /usr/sbin/lpadmin -p ${PRINTER} -E -v socket://${PRINTER}:9100 -P /etc/cups/ppd/${PPD} -o printer-error-policy=retry-job
            ;;
            RICOH)
            cp -f /etc/cups/ppd/RI1511E3.PPD /etc/cups/ppd/${PPD}
            /usr/sbin/lpadmin -p ${PRINTER} -E -v socket://${PRINTER}:9100 -P /etc/cups/ppd/${PPD} -o printer-error-policy=retry-job
            ;;
            LEXMARK)
            cp -f /etc/cups/ppd/LXC935.PPD /etc/cups/ppd/${PPD}
            /usr/sbin/lpadmin -p ${PRINTER} -E -v socket://${PRINTER}:9100 -P /etc/cups/ppd/${PPD} -o printer-error-policy=retry-job
            ;;
            *)
            echo "Impressora não encontrada."
            ;;
        esac
    else
        echo "${LJ} precisa ser inteiro"
    fi
done

#teste_num_loja(){
#    N=$1
#    if [ "${N}" -gt "0" ] 2>/dev/null; then
#        N=$(printf "%04d\n" ${N})
#        ARRLJ=("${ARRLJ[@]}" "${N}")
#    else
#        echo "${N} precisa ser inteiro"
#    fi
#}

#echo "${ARRLJ[@]}"

#for LOJA in $(cat ${LISTA}); do
#    PPD="L${LOJA}_PEGUENALOJA.ppd"
#    PRINTER="L${LOJA}_PEGUENALOJA"
#    /usr/sbin/lpadmin -p ${PRINTER} -E -v socket://${PRINTER}:9100 -P /etc/cups/ppd/${PPD} -o printer-error-policy=retry-job