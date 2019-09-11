#/bin/bash
<<HEADER
    SCRIPT: gera_tab_midas.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para consulta da API do Midas e geração de lista das lojas na nova tesouraria
    VERSION: 1.0 (24/07/2018)
    HISTORY:
HEADER

API="midas.lasa" ## Host da API
AUTH="Authorization: Basic NjU0MzIxOiRNaWRhcy4xMjM=" ## Autenticação com redenciais em Base64
BASE=$(basename $0) ## Nome do script
LOG="/DSOP/DLOG/${BASE%%.*}.log" ## Arquivo de log
TAB="/DSOP/DTAB/LOJAS_MIDAS"
URI="api/store/midas" ## Path da API 
URL="http://${API}/${URI}" ## URL da API

get_api() {
    if ($(nc -zw10 ${API} 80 >/dev/null 2>&1)); then
        echo "$(date '+%F - %T'):" >>${LOG}
        curl -m 10 -s -X GET -H "${AUTH}" "${URL}" |jq -r '.[]|.formattedId' |tee -a ${LOG}
    else
        echo "$(date '+%F - %T')- Erro ao acessar a API." >>${LOG}
        exit 1
    fi
}

get_api >${TAB}