#!/bin/bash
<<INTRO
        Script de execução remota de scripts em PDVs P2K.
        Utilização:

                # exec_cmd_pdv.sh [SCRIPT] [LISTA DE HOSTS] [NOME DO LOG]

        Autor: Agápito Rojas (agapito.rojas@lasa.com.br)

        Versão 1.0 (18/04/2017)
        Versão 1.1 (24/04/2017)
                - Removida saída para log por PDV
                - Alterada saída de execução para tela
                - Incluído teste de host
        Versão 1.2 (20/09/2017)
                - Substituído teste por ping para nmap
INTRO

SHELL="$1" ## Comando a ser executado
LISTA="$2" ## Lista no formato LLLL;PDV;IP
LOJA=$(hostname |cut -c6-)
[ "${LOJA}" -lt 1000 ] && LOJA=0${LOJA}
export SSHPASS="123456" ## Senha do usuário root
SSH="sshpass -e ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR root@"

teste_host(){
        OPEN=$(nmap $1 -p 22 |grep open |wc -l)
}

for LINHA in $(grep ^${LOJA}\; ${LISTA}); do
        LJ=$(echo ${LINHA} |cut -d';' -f1)
        PDV=$(echo ${LINHA} |cut -d';' -f2)
        IP=$(echo ${LINHA} |cut -d';' -f3)
        teste_host ${IP}
        if [ ${OPEN} -eq 1 ]; then
                echo "PDV ${PDV}"
                ${SSH}${IP} "bash -s" < ${SHELL}
        else
                echo "PDV ${PDV} OFFLINE"!
        fi
done