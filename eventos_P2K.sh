#!/bin/bash
:"
  Script de integração dos arquivos de eventos entre o 'lxlasafs01' e 'lxlasa11' para envio às lojas.

  Autor: Agápito Rojas (agapito.rojas@lasa.com.br); utilizado como base 'fideliza_P2K.sh'.
  Versão: 1.0 - 15/09/2016
"
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1

data=$(date +%y%m%d)
ontem=$(date +%y%m%d --date=yesterday)
nome_prog=$(basename $0)
log="${LOG}/${nome_prog}.${data}.log"

pusopo34 "Inicio transmissao" $log

if [ ! -d  /lasa/usr/COMNC/STATX/EVENTO/BACKUP ];then
  mkdir -p /lasa/usr/COMNC/STATX/EVENTO/BACKUP
fi

teste_bkp=$(ls /lasa/usr/COMNC/STATX/EVENTO/*${ontem}*.txt |wc -l)

if [ $teste_bkp -gt 0 ]; then
  pusopo34 "Movendo arquivos para BACKUP" $log
	mkdir -p /lasa/usr/COMNC/STATX/EVENTO/BACKUP/${ontem}/
  mv -f /lasa/usr/COMNC/STATX/EVENTO/*${ontem}*.txt /lasa/usr/COMNC/STATX/EVENTO/BACKUP/*${ontem}*
fi

cd /lasa/usr/COMNC/STATX/EVENTO
if [ $(pwd) == "/lasa/usr/COMNC/STATX/EVENTO" ]; then
  if [ $(ls /nfs/campanhas_eventos_lasafs01/{TDPIT,TEVCARTAO,TEVDEPIT,TEVDESC,TEVGERAL}.*.txt |wc -l  2>&1) -gt 0 ]; then
    echo "Preparando processo de distribuicao"
	  pusopo34 "Preparando processo de distribuicao" $log
    chmod 766 /nfs/campanhas_eventos_lasafs01/{plevgrplj,TDPIT,TEVCARTAO,TEVDEPIT,TEVDESC,TEVGERAL}.*.txt
    rsync -arvgop --remove-source-files /nfs/campanhas_eventos_lasafs01/{plevgrplj,TDPIT,TEVCARTAO,TEVDEPIT,TEVDESC,TEVGERAL}.*.txt .
  else
	  pusopo34 "SEM ARQUIVOS NO LASAFS01" $log
	  echo "SEM ARQUIVOS NO LASAFS01"
  fi
  for lj in $(mysql -h 52.0.8.222 -umon_flash -pmonlasa -N -B  -D monitor_flash -e "select loja from lojas"); do 
    lj=$(echo $lj |sed 's/^0//g')
    for linha in $(cat /lasa/usr/COMNC/STATX/EVENTO/plevgrplj.${data}.*.txt); do
      grupo=$(echo $linha |cut -c1-4)
      loja=$(echo $linha |cut -c5-8 |sed 's/^0//g')
      if [ ! -d  LJ${lj} ]; then
        mkdir LJ${lj}
      else
        echo "Já existe ${lj}."
      fi
      if [ "${lj}" -eq "${loja}" ]; then
        pusopo34 "Inicio distribuicao para LOJA ${lj} " $log	
        rsync -arvh TDPIT.${data}.G${grupo}.*.txt LJ${loja}/TDPIT.txt
        rsync -arvh TEVCARTAO.${data}.G${grupo}.*.txt LJ${loja}/TEVCARTAO.txt
        rsync -arvh TEVDEPIT.${data}.G${grupo}.*.txt LJ${loja}/TEVDEPIT.txt
        rsync -arvh TEVDESC.${data}.G${grupo}.*.txt LJ${loja}/TEVDESC.txt
        rsync -arvh TEVGERAL.${data}.G${grupo}.*.txt LJ${loja}/TEVGERAL.txt
      fi
    done
	done              
fi