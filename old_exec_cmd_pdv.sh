#!/bin/bash
<<INTRO
        Script de execução remota de scripts em PDVs P2K.
        Utilização:

                # exec_cmd_pdv.sh [COMANDO] [LISTA DE HOSTS] [NOME DO LOG]

        Autor: Agápito Rojas (agapito.rojas@lasa.com.br)
INTRO

CMD="$1" ## Comando a ser executado
LISTA="$2" ## Lista no formato LLLL;PDV;IP
SAIDA="$3"
LOJA=$(hostname |cut -c6-)
[ "${LOJA}" -lt 1000 ] && LOJA=0${LOJA}
export SSHPASS="123456" ## Senha do usuário root
SSH="sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR root@"

for LINHA in $(grep ^${LOJA}\; ${LISTA}); do
        LJ=$(echo ${LINHA} |cut -d';' -f1)
        PDV=$(echo ${LINHA} |cut -d';' -f2)
        IP=$(echo ${LINHA} |cut -d';' -f3)
        LOG=/DSOP/DLOG/${SAIDA}.${PDV}.log
        echo "PDV ${PDV}" |tee -a ${LOG}
        ${SSH}${IP} "${CMD}" >>${LOG} 2>&1 &
done