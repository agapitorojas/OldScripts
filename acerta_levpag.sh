#!/bin/bash
<<HEADER
    SCRIPT: acerta_levpag.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para recriar os arquivos "brindes.txt" e "levpag.txt"
    VERSION: 1.0 (17/10/2018)
             1.1 (21/02/2019)
    HISTORY:
             1.1 - Incluída recriação do arquivo "promocao_levpag.tar.bz2" com os arquivos corretos
HEADER

. /DSOP/DEXE/pusopo12 >/dev/null 2>&1

LOJA=$(hostname |cut -c6-)
SSH="ssh -o ConnectTimeout=15 -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o LogLevel=ERROR"

run_cob(){
    export COBSW=-F
    export COBDIR=/opt/microfocus/cobol/
    export LIBPATH=$COBDIR/lib:$LIBPATH:/usr/lib
    cp $VARSTAR/levpag.txt $VARSTAR/../IMAGENS
    cp $VARSTAR/brindes.txt $VARSTAR/../IMAGENS
    cd $CONCENTRADOR
    ./exec/sup01465
    ./gerimprd.bat
}

su rsync -c "${SSH} lxlasa11 \"awk '/^999@|^${LOJA}@/ {print $2}' /LOCAL_STATX/ARQUIVOS/PROMOLEVPAG/NOVO/levpag.txt |cut -d@ -f2\"" >/tmp/levpag.txt.$$ 2>/dev/null
su rsync -c "rsync -gopz --rsh='${SSH}' lxlasa11:/LOCAL_STATX/ARQUIVOS/PROMOLEVPAG/NOVO/brindes.txt /tmp/brindes.txt.$$" 2>/dev/null

if [ -s /tmp/brindes.txt.$$ -a -s /tmp/levpag.txt.$$ ]; then
    find /lasa -type f \( -name brindes.txt -o -name levpag.txt \) -exec rm -f {} \;
    mv -f /tmp/brindes.txt.$$ ${VARSTAR}/brindes.txt
    mv -f /tmp/levpag.txt.$$ ${VARSTAR}/levpag.txt
    run_cob >/dev/null 2>&1
    if [ -x /usr/local/nagios/libexec/check_levpag ]; then
        su nagios -c "/usr/local/nagios/libexec/check_levpag"
        if [ "$?" -eq "0" ]; then
            cd ${VARSTAR}
            tar cjf promocao_levpag.tar.bz2 brindes.txt levpag.txt
        fi
    fi
else
    echo "Erro ao baixar os arquivos."
fi