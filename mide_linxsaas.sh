#!/bin/bash
<<HEADER
    SCRIPT: mide_linxsaas.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script de verificação e edição de parâmetros do PDV para utilização do MID-e SAAS da Linx
    VERSION: 1.0 (02/08/2018)
    HISTORY:
HEADER

MD5OK="1ea2140db48cef43ce5b60abea765b60"
PARAMPDV="/p2k/bin/parametrosGeraisPDV.properties"
URLSAAS="http://mide.linxsaas.com.br/service"

check_resolv() {
    MD5=$(md5sum /etc/resolv.conf |awk '{print $1}')
    if [[ "${MD5}" == "${MD5OK}" ]]; then
        return 0
    else
        return 1
    fi
}

check_param() {
    URL=$(awk '/^PARAM_NFCE_URL_MID/ {print $NF}' /p2k/bin/parametrosGeraisPDV.properties)
    if [[ "${URL}" == "${URLSAAS}" ]]; then
        return 0
    else
        return 1
    fi
}

check_url() {
    curl -m 15 -fsSI ${URLSAAS} >/dev/null 2>&1
    if [[ "$?" -eq "0" ]]; then
        return 0
    else
        return 1
    fi
}

rm -f /p2k/bin/.parametrosGeraisPDV.properties.swp >/dev/null 2>&1
check_resolv
if [ $? -eq 0 ]; then
    echo "resolv.conf OK"
else
    echo "resolv.conf errado"
fi
check_url
if [ $? -eq 0 ]; then
    echo "URL OK"
else
    echo "URL inacessível"
fi
check_param
if [ $? -eq 0 ]; then
    echo "PARAM OK"
else
    echo "PARAM errado"
fi