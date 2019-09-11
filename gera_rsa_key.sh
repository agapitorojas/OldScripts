#!/bin/bash
<<HEADER

    SCRIPT: gera_rsa_key.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para geração de chaves SSH RSA (4096 bits)
    VERSION: 1.0 (29/01/2018)
    HISTORY:

HEADER

rm -f /home/rsync/.ssh/id_rsa* ## Remove chaves antigas caso existam
su rsync -c "ssh-keygen -t rsa -b 4096 -f id_rsa -N ''" ## Cria chave RSA com 4096 bits sem passphrase