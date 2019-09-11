#!/bin/bash
LOJAS=($(/bin/su nagios -c "ssh piprod@ibmsappi03 'find /RSYNC/ARQUIVOS/SORTIMENTOS/* -prune -type f -name 'T_lotesort.??????.??????.????????????????.????' -mmin +5 2>/dev/null'" |cut -d. -f5 |sort -n |uniq))
EXIT=$?

monta_email(){
    if [ ${EXIT} = 0 ]; then
        if [ ${#LOJAS[@]} -gt 0 ]; then
            ARQ=0
            for LJ in ${LOJAS[@]}; do
                QTD=$(/bin/su nagios -c "ssh piprod@ibmsappi03 'find /RSYNC/ARQUIVOS/SORTIMENTOS/* -prune -type f -name 'T_lotesort.??????.??????.????????????????.${LJ}' 2>/dev/null'" |wc -l)
                if [ ${QTD} -gt 0 ]; then
                    echo -e "========================================\n${QTD} arquivos para a loja${LJ}\n========================================"
                    ARQ=1
                fi
            done
            if [ ${ARQ} -eq 0 ]; then
                echo -e "======= Sem arquivos T_lotesort retidos em /RSYNC/ARQUIVOS/SORTIMENTOS/ ======="
            fi
        else
            echo -e "======= Sem arquivos T_lotesort retidos em /RSYNC/ARQUIVOS/SORTIMENTOS/ ======="
        fi
    else
        echo -e "======= Erro ${EXIT} ao acessar IBMSAPPI03 ======="
    fi
}

monta_email | /bin/mail -s "Arquivos T_lotesor* no IBMSAPPI03" -r nagioscore@lasa.com.br suporteux-lasa@lasa.com.br producao.lasa@lasa.com.br operadoressede@lasa.com.br betav@br.ibm.com hlima@br.ibm.com ti-comercial@lasa.com.br