#!/bin/bash

for DIA in $(seq -w 31); do
    if [ -f /lasa1/pdvs/dados/bk${DIA}/LOTESORT ]; then
        rm -f /lasa1/pdvs/dados/bk${DIA}/LOTESORT && \
        mkdir -p /lasa1/pdvs/dados/bk${DIA}/LOTESORT && \
        chmod 777 /lasa1/pdvs/dados/bk${DIA}/LOTESORT
    elif [ ! -d /lasa1/pdvs/dados/bk${DIA}}/LOTESORT ]; then
        mkdir -p /lasa1/pdvs/dados/bk${DIA}/LOTESORT && \
        chmod 777 /lasa1/pdvs/dados/bk${DIA}/LOTESORT
    fi
done