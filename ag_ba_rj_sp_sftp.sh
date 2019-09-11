#!/bin/ksh

##########################################################################################
# Objetivo: TRANSFERENCIA DE ARQUIVOS ENTRE CDS E TILOGISTICA 
#      arquivos:     appt
#      arquivos:     so_w 
#      arquivos:     contagem_LC2 
#      arquivos:     bol
#           SERVIDORES ENVOLVIDOS
#                       IBMSAP04
#           LASAFTP2(200.142.192.99)
#                       SCRIPT (ibmrsnc01 - 10.23.87.205) /DSOP/RSYNC/ag_rj_sp_sftp.sh
###########################################################################################

data=`date +%d%m%Y`

#######################################################################################################
#ENVIO CDSP
#######################################################################################################

echo "Arquivos 180"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agsp.ENVIO.$data.log
echo "INICIO ENVIO - CDSP" >> /DSOP/DLOG/rsync.agsp.ENVIO.$data.log
date >> /DSOP/DLOG/rsync.agsp.ENVIO.$data.log

#AGENDA
rsync -rlvz --timeout=30 --chmod go+rw /RSYNC/IBMSAP04/STATX/AG/AGENDA/DAT/appt.L180* /RSYNC/IBMSAP04/STATX/AG/AGENDA/BACKUP/ 

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh /RSYNC/IBMSAP04/STATX/AG/AGENDA/DAT/appt.L180* rsync@200.142.192.99:/lasa/home/agsp/STARX/AG/AGENDA/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agsp.ENVIO.$data.log 


#S_ORDER
rsync -rlvz --timeout=30 --chmod go+rw /RSYNC/IBMSAP04/STATX/AG/S_ORDER/DAT/so_w.L180* /RSYNC/IBMSAP04/STATX/AG/S_ORDER/BACKUP/ 

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh /RSYNC/IBMSAP04/STATX/AG/S_ORDER/DAT/so_w.L180* rsync@200.142.192.99:/lasa/home/agsp/STARX/AG/S_ORDER/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agsp.ENVIO.$data.log 
echo "FIM ENVIO - CDSP" >> /DSOP/DLOG/rsync.agsp.ENVIO.$data.log
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agsp.ENVIO.$data.log

#######################################################################################################
#ENVIO CDRJ
#######################################################################################################

echo "Arquivos 151"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agrj.ENVIO.$data.log
echo "INICIO ENVIO - CDRJ" >> /DSOP/DLOG/rsync.agrj.ENVIO.$data.log
date >> /DSOP/DLOG/rsync.agrj.ENVIO.$data.log


#AGENDA
rsync -rlvz --timeout=30 --chmod go+rw /RSYNC/IBMSAP04/STATX/AG/AGENDA/DAT/appt.L151* /RSYNC/IBMSAP04/STATX/AG/AGENDA/BACKUP/ 

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh /RSYNC/IBMSAP04/STATX/AG/AGENDA/DAT/appt.L151* rsync@200.142.192.99:/lasa/home/agrj/STARX/AG/AGENDA/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agrj.ENVIO.$data.log 

#S_ORDER
rsync -rlvz --timeout=30 --chmod go+rw /RSYNC/IBMSAP04/STATX/AG/S_ORDER/DAT/so_w.L151* /RSYNC/IBMSAP04/STATX/AG/S_ORDER/BACKUP/ 

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh /RSYNC/IBMSAP04/STATX/AG/S_ORDER/DAT/so_w.L151* rsync@200.142.192.99:/lasa/home/agrj/STARX/AG/S_ORDER/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agrj.ENVIO.$data.log 

echo "FIM ENVIO - CDRJ" >> /DSOP/DLOG/rsync.agrj.ENVIO.$data.log
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agrj.ENVIO.$data.log

#######################################################################################################
#ENVIO CDBA
#######################################################################################################

echo "Arquivos 219"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agba.ENVIO.$data.log
echo "INICIO ENVIO - CDBA" >> /DSOP/DLOG/rsync.agba.ENVIO.$data.log
date >> /DSOP/DLOG/rsync.agba.ENVIO.$data.log


#AGENDA
rsync -rlvz --timeout=30 --chmod go+rw /RSYNC/IBMSAP04/STATX/AG/AGENDA/DAT/appt.D219* /RSYNC/IBMSAP04/STATX/AG/AGENDA/BACKUP/ 

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh /RSYNC/IBMSAP04/STATX/AG/AGENDA/DAT/appt.D219* rsync@200.142.192.99:/lasa/home/agba/STARX/AG/AGENDA/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agba.ENVIO.$data.log 

#S_ORDER
rsync -rlvz --timeout=30 --chmod go+rw /RSYNC/IBMSAP04/STATX/AG/S_ORDER/DAT/so_w.D219* /RSYNC/IBMSAP04/STATX/AG/S_ORDER/BACKUP/ 

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh /RSYNC/IBMSAP04/STATX/AG/S_ORDER/DAT/so_w.D219* rsync@200.142.192.99:/lasa/home/agba/STARX/AG/S_ORDER/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agba.ENVIO.$data.log 

echo "FIM ENVIO - CDBA" >> /DSOP/DLOG/rsync.agba.ENVIO.$data.log
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agba.ENVIO.$data.log

#######################################################################################################
#RETORNO CDSP
#######################################################################################################

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agsp.RETORNO.$data.log
echo "INICIO RETORNO - CDSP" >> /DSOP/DLOG/rsync.agsp.RETORNO.$data.log
date >> /DSOP/DLOG/rsync.agsp.RETORNO.$data.log

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh rsync@200.142.192.99:/lasa/home/agsp/STATX/RECEBFIS/DAT/contagem_LC2.L180* /RSYNC/IBMSAP04/STARX/AG/RECEBFIS/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agsp.RETORNO.$data.log 
rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh rsync@200.142.192.99:/lasa/home/agsp/STATX/BOL/DAT/bol.L180* /RSYNC/IBMSAP04/STARX/AG/BOL/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agsp.RETORNO.$data.log

echo "FIM RETORNO - CDSP" >> /DSOP/DLOG/rsync.agsp.RETORNO.$data.log
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agsp.RETORNO.$data.log


#######################################################################################################
#RETORNO CDRJ
#######################################################################################################

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agrj.RETORNO.$data.log
echo "INICIO RETORNO - CDRJ" >> /DSOP/DLOG/rsync.agrj.RETORNO.$data.log
date >> /DSOP/DLOG/rsync.agrj.RETORNO.$data.log

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh rsync@200.142.192.99:/lasa/home/agrj/STATX/RECEBFIS/DAT/contagem_LC2.L151* /RSYNC/IBMSAP04/STARX/AG/RECEBFIS/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agrj.RETORNO.$data.log 
rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh rsync@200.142.192.99:/lasa/home/agrj/STATX/BOL/DAT/bol.L151* /RSYNC/IBMSAP04/STARX/AG/BOL/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agrj.RETORNO.$data.log 

echo "FIM RETORNO - CDRJ" >> /DSOP/DLOG/rsync.agrj.RETORNO.$data.log

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agrj.RETORNO.$data.log

#######################################################################################################
#RETORNO CDBA
#######################################################################################################

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agba.RETORNO.$data.log
echo "INICIO RETORNO - CDBA" >> /DSOP/DLOG/rsync.agba.RETORNO.$data.log
date >> /DSOP/DLOG/rsync.agba.RETORNO.$data.log

rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh rsync@200.142.192.99:/lasa/home/agba/STATX/RECEBFIS/DAT/contagem_LC2.D219* /RSYNC/IBMSAP04/STARX/AG/RECEBFIS/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agba.RETORNO.$data.log 
rsync -rlvz --remove-sent-files --timeout=30 --chmod go+rw -p -e ssh rsync@200.142.192.99:/lasa/home/agba/STATX/BOL/DAT/bol.D219* /RSYNC/IBMSAP04/STARX/AG/BOL/DAT/ 2>&1 >> /DSOP/DLOG/rsync.agba.RETORNO.$data.log 

echo "FIM RETORNO - CDBA" >> /DSOP/DLOG/rsync.agba.RETORNO.$data.log

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"  >> /DSOP/DLOG/rsync.agba.RETORNO.$data.log

find /DSOP/DLOG/ -name "rsync*.log" -mtime +5 -exec rm -f {} \;
