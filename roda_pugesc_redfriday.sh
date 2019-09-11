. /DSOP/DEXE/pusopo12 >/dev/null 2>&1
LOJA=$(hostname |cut -d_ -f2)

export COBSW=-F
export COBDIR=/opt/microfocus/cobol/
export LIBPATH=$COBDIR/lib:$LIBPATH:/usr/lib
export TERM=vt100

cd /lasa1/pdvs/dados/exec
echo "$(date '+%F %T'): Executando pugesc01."
sleep 1
sh /DSOP/DEXE/pugesc01
if [ $? -eq 0 ]; then
    echo "$(date '+%F %T'): Executado pugesc01 com sucesso."
    sleep 1
    echo "$(date '+%F %T'): Executando pa01120."
    sleep 1
    cd /lasa/pdvs/dados
    ./exec/pa01120
    if [ $? -eq 0 ]; then
        echo "$(date '+%F %T'): Executado pa01120 com sucesso."
    else
        echo "$(date '+%F %T'): Erro na execução do pa01120."
    fi
    echo "$(date '+%F %T'): Executando sup01465."
    sleep 1
    ./exec/sup01465
    if [ $? -eq 0 ]; then
    echo "$(date '+%F %T'): Executado sup01465 com sucesso."
    else
        echo "$(date '+%F %T'): Erro na execução do sup01465."
    fi
    echo "$(date '+%F %T'): Executando gerimprd.bat."
    sleep 1
    ./gerimprd.bat
    if [ $? -eq 0 ]; then
    echo "$(date '+%F %T'): Executado gerimprd.bat com sucesso."
    else
        echo "$(date '+%F %T'): Erro na execução do gerimprd.bat."
    fi
else
    echo "$(date '+%F %T'): Erro na execução do pugesc01."
fi