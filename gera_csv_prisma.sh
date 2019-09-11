#!/bin/bash
<<INTRO
  Script de criação de arquivo CSV para utilização no IBMRSNC01.
INTRO

DB="52.31.153.88"
USER="mon_flash"
PASS="monlasa"

for LJ in $(mysql -h ${DB} -BNp -u${USER} -p${PASS} -e "select loja from monitor_flash.tipo_loja where TIPO_LOJA like '%PRISMA%';"); do 
  IP=$(ver_end ${LJ} |cut -f1)
  echo "${LJ};${IP}"
done