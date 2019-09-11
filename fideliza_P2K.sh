#!/bin/bash


export TERM=vt100
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1

data=`date +%y%m%d`
#data=`date +%y%m%d --date=yesterday`
ontem=`date +%y%m%d --date=yesterday`

nome_prog=`basename $0`
log="${LOG}/${nome_prog}.${data}.log"

pusopo34 "Inicio transmissao" $log


    if [ ! -d  /lasa/usr/COMNC/STATX/FIDELIZACAO/BACKUP ]
     then
       mkdir /lasa/usr/COMNC/STATX/FIDELIZACAO/BACKUP
    fi

	teste_bkp=`ls /lasa/usr/COMNC/STATX/FIDELIZACAO/*${ontem}*.txt |wc -l`

  	if [ $teste_bkp -gt 0 ]
           then

	   pusopo34 "Movendo arquivos para BACKUP" $log
	      mkdir /lasa/usr/COMNC/STATX/FIDELIZACAO/BACKUP/${ontem}/
              mv -f /lasa/usr/COMNC/STATX/FIDELIZACAO/*${ontem}*.txt /lasa/usr/COMNC/STATX/FIDELIZACAO/BACKUP/*${ontem}*

	fi

	cd /lasa/usr/COMNC/STATX/FIDELIZACAO


       if [ `pwd` == "/lasa/usr/COMNC/STATX/FIDELIZACAO" ]
        then

          if [ `ls /nfs/fidelizacao_lasafs01/*.txt |wc -l  2>&1` -gt 0 ] 
           then


		echo "Preparando processo de distribuicao"
		pusopo34 "Preparando processo de distribuicao" $log
              rsync -arvgop --remove-source-files /nfs/fidelizacao_lasafs01/*.txt .

	   else

		pusopo34 "SEM ARQUIVOS NO LASAFS01" $log
		echo "SEM ARQUIVOS NO LASAFS01"


          fi









               for lj in `mysql -h 52.0.8.222 -umon_flash -pmonlasa -N -B  -D monitor_flash -e "select loja from lojas"`
                do 

			lj=`echo $lj |sed 's/^0//g'`
                    for linha in `cat /lasa/usr/COMNC/STATX/FIDELIZACAO/rdgrplj.${data}.*.txt`
                     do

                        grupo=`echo $linha |cut -c1-4`
                        loja=`echo $linha |cut -c5-8 |sed 's/^0//g'`


                            if [ ! -d  LJ${lj} ]
                             then
                               mkdir LJ${lj}
                            else
                              echo ja existe $lj
                            fi

                                if [ "${lj}" -eq "${loja}" ]
                                 then
				 pusopo34 "Inicio distribuicao para LOJA ${lj} " $log	

                                    rsync -arvh rddet.${data}.${grupo}.*.txt LJ${loja}
                                    rsync -arvh regras.${data}.${grupo}.*.txt LJ${loja}
                                fi





                    done
	         done              
              fi
