#!/bin/bash
#
## Script para envio de arquivos para lojas via RSYNC ##
##
#Utilização:
#
# ./enviarquivoloja.sh [arquivo] [destino] [lista de lojas] [nome do log]
#

for LJ in $(cat $3); do

LOG=../Logs/$4.${NLJ}.log
RPAR="-vogpz --progress"
SPAR="-q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l sma"
ORIG=$1
DTN=$2
NIP=`ver_end ${NLJ} | grep Loja | tr -s "\t" " " | cut -d" " -f1`

echo "LOJA "${NLJ}
echo "LOJA ${NLJ}" >>${LOG}

rsync ${RPAR} --rsh="sshpass -p r0ux1n0l ssh ${SPAR}" ${ORIG} ${NIP}:${DTN} >>${LOG} 2>&1 && echo OK >>${LOG} 2>&1 &

done