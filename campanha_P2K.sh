#!/bin/bash
:"
  Script de integração dos arquivos de campanha entre o 'lxlasafs01' e 'lxlasa11' para envio às lojas.

  Autor: Agápito Rojas (agapito.rojas@lasa.com.br); utilizado como base 'fideliza_P2K.sh'.
  Versão: 1.0 - 12/09/2016
"
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1

data=$(date +%Y%m%d)
ontem=$(date +%Y%m%d --date=yesterday)
nome_prog=$(basename $0)
log="${LOG}/${nome_prog}.${data}.log"

pusopo34 "Inicio transmissao" $log

if [ ! -d  /lasa/usr/COMNC/STATX/CAMPANHA/BACKUP ];then
  mkdir -p /lasa/usr/COMNC/STATX/CAMPANHA/BACKUP
fi

teste_bkp=$(ls /lasa/usr/COMNC/STATX/CAMPANHA/*${ontem}*.txt |wc -l)

if [ $teste_bkp -gt 0 ]; then
  pusopo34 "Movendo arquivos para BACKUP" $log
	mkdir -p /lasa/usr/COMNC/STATX/CAMPANHA/BACKUP/${ontem}/
  mv -f /lasa/usr/COMNC/STATX/CAMPANHA/*${ontem}*.txt /lasa/usr/COMNC/STATX/CAMPANHA/BACKUP/*${ontem}*
fi

cd /lasa/usr/COMNC/STATX/CAMPANHA
if [ $(pwd) == "/lasa/usr/COMNC/STATX/CAMPANHA" ]; then
  if [ $(ls /nfs/campanhas_eventos_lasafs01/{brindes,campgrplj,levpag}.*.txt |wc -l  2>&1) -gt 0 ]; then
    echo "Preparando processo de distribuicao"
	  pusopo34 "Preparando processo de distribuicao" $log
    rsync -arvgop --remove-source-files /nfs/campanhas_eventos_lasafs01/{brindes,campgrplj,levpag}.*.txt .
    chmod 777 {brindes,campgrplj,levpag}.*.txt
  else
	  pusopo34 "SEM ARQUIVOS NO LASAFS01" $log
	  echo "SEM ARQUIVOS NO LASAFS01"
  fi
  for lj in $(mysql -h 52.0.8.222 -umon_flash -pmonlasa -N -B  -D monitor_flash -e "select loja from lojas"); do 
    lj=$(echo $lj |sed 's/^0//g')
    for linha in $(cat /lasa/usr/COMNC/STATX/CAMPANHA/campgrplj.${data}.*.txt); do
      grupo=$(echo $linha |cut -c1-4)
      loja=$(echo $linha |cut -c5-8 |sed 's/^0//g')
      if [ ! -d  LJ${lj} ]; then
        mkdir LJ${lj}
      else
        echo "Já existe ${lj}."
      fi
      if [ "${lj}" -eq "${loja}" ]; then
        pusopo34 "Inicio distribuicao para LOJA ${lj} " $log	
        rsync -arvh levpag.${data}.G${grupo}.*.txt LJ${loja}/levpag.txt
        rsync -arvh brindes.${data}.G${grupo}.*.txt LJ${loja}/brindes.txt
      fi
    done
	done              
fi