##############################################
# puvda002a
#
# Gera arquivo com todas as vendas a partir dos lgcx
# da vanguarda Prisma e ordena.
#
# Programas chamados:
#	sup01250 (em Cobol)
#
# Data: 10/2003
# Historico:
# 	5/2004: Considera-se tb os fechamentos de cupons
#	3/2006: Considera-se tb os arquivos de venda do tipo lgcx???b 
#               (Wanderson Carvalho)
#       4/2006: Realizados Acertos na verficacao  de existencia do arquivo  
#    10/7/2009: trocado puvda003 pelo sup01250
##############################################
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1

[ $# -ne 1 ] && exit 0

DDADOS=$1

saida(){

echo "dados" >$CONCENTRADOR/camflash.txt
chmod 444 $CONCENTRADOR/camflash.txt
exit 
}

umask 000
export novodir=$VARSTAT/LXLASA
export dirtrab=$VARSTAR/FLASH
export DIRSAIDA=$dirtrab/SAIDA

[ ! -d $novodir ] && mkdir -p $novodir
[ ! -d $dirtrab ] && mkdir -p $dirtrab
[ ! -d $DIRSAIDA ] && mkdir -p $DIRSAIDA

dirvendas=/lasa/pdvs/${DDADOS}

#  forca diretorio de leitura dos logs de vendas

echo "${DDADOS}" >$CONCENTRADOR/camflash.txt
chmod 444 $CONCENTRADOR/camflash.txt

#
#

dirprog=$CONCENTRADOR/exec
logfile=$dirtrab/LOG/puvda002.log

loja=""

case `uname` in
AIX)
	ZIP="/opt/freeware/bin/gzip"
	loja=`hostname | cut -c6-`
	break ;;
HP-UX)
	ZIP="/usr/contrib/bin/gzip"
	loja=`hostname | cut -c3-`
	break ;;
Linux)
	ZIP="/bin/gzip"
	loja=`hostname | cut -c6-`
        [ $loja -lt 1000 ] && loja=0${loja}
	;;
CYGWIN_NT-5.0)
	ZIP="/bin/gzip"
	loja="145"
	;;
esac

# testa presenca de arquivos

if [ `ls $dirvendas/lgcx??? $dirvendas/lgcx???b 2>/dev/null | wc -l` -gt 0 ]
then

   if [ ! -d $DIRSAIDA ]
   then
      echo "ERRO. Diretorio: $DIRSAIDA inexistente!"
      saida
   fi

   datahoraatual=`date +%Y%m%d%H`

   ################################################

   echo "Inicio sup01250:`date +%y%m%d-%H%M%S`" >> $logfile
   
   $dirprog/sup01250 >>$logfile 2>&1

   echo "Fim    sup01250:`date +%y%m%d-%H%M%S`" >> $logfile

   sort -T $dirtrab $DIRSAIDA/vendas.txt | uniq > $dirtrab/.vendas.tmp
   
   mv -f $dirtrab/.vendas.tmp $dirtrab/vendas
   chmod 666 $dirtrab/vendas

   ###################
   # CUPONS FECHADOS
   ###################

   # ordena fechamentos para poder obter diferencas a frente

   sort -T $dirtrab $DIRSAIDA/arq_fech_cup.txt > $DIRSAIDA/cupf_ord.$loja

   # se existe anterior compara

   if [ -s $DIRSAIDA/cupf_ord.$loja.ant ]
   then

      # obtem diferencial das vendas geradas

      comm -23 $DIRSAIDA/cupf_ord.$loja \
        $DIRSAIDA/cupf_ord.$loja.ant > $DIRSAIDA/cupf_trans.$loja

      if [ -s $DIRSAIDA/cupf_trans.$loja ] && [ $? -eq 0 ]
      then
	    sed "s/^/$loja/" $DIRSAIDA/cupf_trans.$loja | \
            $ZIP -f > $DIRSAIDA/cupf_trans.$loja.gz
	    ERRO=$?

	  if [ $ERRO -eq 0 ]
	  then
            data=`date +%y%m%d%H%M%S`
            mv -f $DIRSAIDA/cupf_trans.$loja.gz \
	      ${novodir}/cupf_trans.$loja.${data}.gz
	  fi
      fi
   else
      if [ -s $DIRSAIDA/cupf_ord.$loja ]
      then
    	 data=`date +%y%m%d%H%M%S`
	     	sed "s/^/$loja/" $DIRSAIDA/cupf_ord.$loja | \
         	$ZIP -f > $novodir/cupf_trans.$loja.${data}.gz
      fi
   fi

   mv -f $DIRSAIDA/cupf_ord.$loja $DIRSAIDA/cupf_ord.$loja.ant

   ###################
   # CUPONS CANCELADOS
   ###################

   sort -T $dirtrab $DIRSAIDA/arq_cup_canc.txt > \
     $DIRSAIDA/cupc_ord.$loja

   if [ -s $DIRSAIDA/cupc_ord.$loja.ant ]
   then
      comm -23 $DIRSAIDA/cupc_ord.$loja $DIRSAIDA/cupc_ord.$loja.ant > \
        $DIRSAIDA/cupc_trans.$loja

      if [ -s $DIRSAIDA/cupc_trans.$loja ] && [ $? -eq 0 ]
      then
       sed "s/^/$loja/" $DIRSAIDA/cupc_trans.$loja | \
            $ZIP -f > $DIRSAIDA/cupc_trans.$loja.gz

	  if [ $? -eq 0 ]
	  then
	    data=`date +%y%m%d%H%M%S`
            mv -f $DIRSAIDA/cupc_trans.$loja.gz \
	      ${novodir}/cupc_trans.$loja.${data}.gz
	  fi
      fi
   else
      if [ -s $DIRSAIDA/cupc_ord.$loja ]
      then
	data=`date +%y%m%d%H%M%S`
	 sed "s/^/$loja/" $DIRSAIDA/cupc_ord.$loja | \
            $ZIP -f > $novodir/cupc_trans.$loja.${data}.gz
      fi
   fi

   mv -f $DIRSAIDA/cupc_ord.$loja $DIRSAIDA/cupc_ord.$loja.ant

   #################
   # CREDITO DIGITAL  -  ALTERADO PARA TRATAR ARQUIVOS DO TOTEM VIDEOSOFT
   #################

   sed "s/^/$loja/" < $DIRSAIDA/arq_crd_digi.txt > \
     $DIRSAIDA/cupd_ord.$loja
 
   if [ -d /lasa/usr/COMNC/TOTEM_VIDEOSOFT ]
   then
 
      find /lasa/usr/COMNC/TOTEM_VIDEOSOFT/vendas_totem.txt.???????? -print | \
      while read ARQTOTEM
      do
   	cat ${ARQTOTEM} >>$DIRSAIDA/cupd_ord.$loja
   	[ $? -eq 0 ] && rm -f ${ARQTOTEM}
      done
   fi

   sort -T $dirtrab $DIRSAIDA/cupd_ord.$loja | uniq > $DIRSAIDA/cupd_ord.$loja.XX
   mv $DIRSAIDA/cupd_ord.$loja.XX $DIRSAIDA/cupd_ord.$loja

   if [ -s $DIRSAIDA/cupd_ord.$loja.ant ]
   then
      comm -23 $DIRSAIDA/cupd_ord.$loja $DIRSAIDA/cupd_ord.$loja.ant > \
         $DIRSAIDA/cupd_trans.$loja

      if [ -s $DIRSAIDA/cupd_trans.$loja ] && [ $? -eq 0 ]
      then
         $ZIP -f $DIRSAIDA/cupd_trans.$loja

	 if [ $? -eq 0 ]
	 then
	    data=`date +%y%m%d%H%M%S`
            mv -f $DIRSAIDA/cupd_trans.$loja.gz \
	       ${novodir}/cupd_trans.$loja.${data}.gz
	 fi
      fi
   else
      if [ -s $DIRSAIDA/cupd_ord.$loja ]
      then
         data=`date +%y%m%d%H%M%S`
         $ZIP -f $DIRSAIDA/cupd_ord.$loja
	 [ $? -eq 0 ] && mv $DIRSAIDA/cupd_ord.$loja.gz $novodir/cupd_trans.$loja.${data}.gz
      fi
   fi

   mv -f $DIRSAIDA/cupd_ord.$loja $DIRSAIDA/cupd_ord.$loja.ant

else
   saida
fi

#########################################
# preparar arquivos compactados de vendas
# que serao enviados a servidor MySql
#########################################

if [ -f $dirtrab/vda.$loja ]
then

   if [ -f $dirtrab/vendas ]
   then
      # crio arquivo com as vendas nao contidas no arquivo
      # gerado na cron anterior

      comm -13 $dirtrab/vda.$loja $dirtrab/vendas > $dirtrab/dif.$loja
      cp $dirtrab/vendas $dirtrab/vda.$loja

      if [ -s $dirtrab/dif.$loja ]
      then
         # acrescento numero da loja aos registros como primeiro campo

	 sed "s/^/$loja\ /" $dirtrab/dif.$loja > $dirtrab/ALLtosrv.$loja
         rm -f $dirtrab/.nlj.tmp
      else
         saida
      fi

   else
      rm -f $dirtrab/vda.$loja
      saida
   fi

else # cria arquivo comparativo de vendas pela primeira vez

   if [ -f $dirtrab/vendas ]
   then
      touch $dirtrab/vda.$loja # crio arquivo comparacao zerado
      comm -13 $dirtrab/vda.$loja $dirtrab/vendas > $dirtrab/dif.$loja
      # acrescento numero da loja aos registros como primeiro campo
      sed "s/^/$loja\ /" $dirtrab/dif.$loja > $dirtrab/ALLtosrv.$loja
      cp $dirtrab/vendas $dirtrab/vda.$loja
   else # neste caso houve algum problema na criacao das vendas
      saida
   fi
fi

# crio extensao timestamp compacto arquivo a enviar e movo para repositorio local

###
##  Separa vendas em KIT das vendasunitarias
###

if [ -s $dirtrab/ALLtosrv.$loja ]
then

	grep " 000000000000 [0-9|a-z|A-Z] " $dirtrab/ALLtosrv.$loja | cut -d" " -f1-15,17- | sed "s/ G / 1 /g" >$dirtrab/tosrv.$loja

	grep -v " 000000000000 [0-9|a-z|A-Z] " $dirtrab/ALLtosrv.$loja | sed "s/ G / 1 /g" >$dirtrab/kittosrv.$loja

[ ! -s $dirtrab/tosrv.$loja ] && rm -f $dirtrab/tosrv.$loja
[ ! -s $dirtrab/kittosrv.$loja ] && rm -f $dirtrab/kittosrv.$loja


#

extensao=`date +%y%m%d%H%M%S.gz`
[ -s  $dirtrab/tosrv.$loja ] && $ZIP < $dirtrab/tosrv.$loja > $dirtrab/.tosrv.$loja.$extensao
[ -s $dirtrab/kittosrv.$loja ] && $ZIP <$dirtrab/kittosrv.$loja > $dirtrab/.kittosrv.$loja.$extensao

##

[ -s  $dirtrab/.tosrv.$loja.$extensao ] && mv $dirtrab/.tosrv.$loja.$extensao ${novodir}/tosrv.$loja.$extensao
[ -s  $dirtrab/.kittosrv.$loja.$extensao ] && mv $dirtrab/.kittosrv.$loja.$extensao ${novodir}/kittosrv.$loja.$extensao

fi

chmod 777 ${novodir}/*
chown rsync:500 ${novodir}/*
# TUDO OK

echo "dados" >$CONCENTRADOR/camflash.txt
chmod 444 $CONCENTRADOR/camflash.txt

saida


