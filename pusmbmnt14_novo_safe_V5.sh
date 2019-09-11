# Scrit de integração de arquivos entre SAFE-FAI e SFTP, alterado para a inclusão do novo SAFE (UOL)
# Data de criação: 13/11/2015 (editado do pusmbmnt14_nova_tes)
#
# Versão: 5
#         2015-01-07: Inclusão do envio dos aquidos de GE para o LASASCE exclusão do SAFE antigo SAFE (Sede)
#  
export TERM=vt100
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1

nome_prog=`basename $0`
log="${LOG}/${nome_prog}.log"

enviamail(){
  MSG="$1"
  usuarios="suporteunix"
  echo "1:${usuarios}
  2:${MSG} `hostname`
  `hostname` ${MSG}" >>/tmp/mailflash.$$
  /DSOP/DEXE/email_lasa /tmp/mailflash.$$
}

alerta(){
  msg="Erro ${1} GARANTIA ESTENDIDA ${nome_prog}"
  pusopo34 "${msg}" $log
	enviamail "${msg}"
}

[ ! -d /LOCAL_STATX/GARANTIA/IBMCOM01 ] && mkdir -p /LOCAL_STATX/GARANTIA/IBMCOM01

pusopo34 "Inicio transacao" $log

mount -v | grep "52.31.152.14/ftproot" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  umount -l /smbfs/LASASCE02/ftproot
  sleep 2
  mount -t cifs -o username=dif,password=ibm12@lasa //52.31.152.14/ftproot /smbfs/LASASCE02/ftproot
fi

mount -v | grep -i "10.23.94.84/integracao_safe_fai" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  umount -l /smbfs/SAFE_FAI_NOVO/integracao
  sleep 2
  mount -t cifs -o username=usr_linux_share,password=@L@sa@Unix,workgroup=lasa.com //10.23.94.84/integracao_safe_fai /smbfs/SAFE_FAI_NOVO/integracao
fi  

# Copia arquivos entre SAFE_FAI e localhost

mount -v | grep "52.31.152.14/ftproot" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  mount -v | grep -i "10.23.94.84/integracao_safe_fai" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    if [ `ls /LOCAL_STATX/GARANTIA/SAFE_FAI/PR* 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /LOCAL_STATX/GARANTIA/SAFE_FAI/PR* /smbfs/SAFE_FAI_NOVO/integracao/001 >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 20
   	  sleep 1
    fi
    if [ `ls /LOCAL_STATX/GARANTIA/SAFE_FAI/TR* 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /LOCAL_STATX/GARANTIA/SAFE_FAI/TR* /smbfs/SAFE_FAI_NOVO/integracao/002 >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 40
      sleep 1
    fi
    if [ `ls /LOCAL_STATX/GARANTIA/SAFE_FAI/VR* 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /LOCAL_STATX/GARANTIA/SAFE_FAI/VR* /smbfs/SAFE_FAI/integracao/003 >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 60
      sleep 1
    fi
    if [ `ls /LOCAL_STATX/GARANTIA/SAFE_FAI/TG*SOL* 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /LOCAL_STATX/GARANTIA/SAFE_FAI/TG*SOL* /smbfs/SAFE_FAI_NOVO/integracao/010 >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 60
      sleep 1
    fi
    if [ `ls /smbfs/SAFE_FAI_NOVO/integracao/006/ME* 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v /smbfs/SAFE_FAI_NOVO/integracao/006/ME* /smbfs/LASASCE02/ftproot/ENTRADA/GE_SAFE >>$log 2>&1
      /usr/bin/rsync -v --remove-sent-files /smbfs/SAFE_FAI_NOVO/integracao/006/ME* /LOCAL_STARX/GARANTIA/SAFE_FAI >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 80
      sleep 1
    fi
    if [ `ls /smbfs/SAFE_FAI/integracao/008/????????.0000 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /smbfs/SAFE_FAI/integracao/008/????????.0000 /LOCAL_STATX/GARANTIA/IBMCOM01  >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 100
      sleep 1
    fi
    if [ `ls /smbfs/SAFE_FAI/integracao/009/????????.???? 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /smbfs/SAFE_FAI/integracao/009/????????.???? /LOCAL_STATX/GARANTIA/IBMCOM01  >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 120
      sleep 1
    fi
    if [ `ls /smbfs/SAFE_FAI_NOVO/integracao/011/TG*PAG* 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /smbfs/SAFE_FAI_NOVO/integracao/011/TG*PAG* /LOCAL_STARX/GARANTIA/SAFE_FAI  >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 80
      sleep 1
    fi
    if [ `ls /LOCAL_STATX/GARANTIA/SAFE_FAI/MAPFRESOL* 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /LOCAL_STATX/GARANTIA/SAFE_FAI/MAPFRESOL* /smbfs/SAFE_FAI_NOVO/integracao/012 >>$log 2>&1
      [ $? -ne 0 -a $? -ne 23 ] && alerta 60
    sleep 1
    fi
    if [ `ls /smbfs/SAFE_FAI_NOVO/integracao/013/MAPFREPAG* 2>/dev/null | wc -l` -gt 0 ]; then
      /usr/bin/rsync -v --remove-sent-files /smbfs/SAFE_FAI_NOVO/integracao/013/MAPFREPAG* /LOCAL_STARX/GARANTIA/SAFE_FAI  >>${log} 2>&1 
      [ $? -ne 0 -a $? -ne 23 ] && alerta 80
      sleep 1
    fi
  else
    alerta 11
  fi
else
	alerta 10
fi

# Enviando arquivos para IBMCOM01

if [ `ls /LOCAL_STATX/GARANTIA/IBMCOM01/????????.???? 2>/dev/null | wc -l` -gt 0 ]; then
 	/usr/bin/rsync -v  --remove-sent-files /LOCAL_STATX/GARANTIA/IBMCOM01/????????.???? /nfs/ibmcom01_prd_tesouraria/safe/safe_in >>$log 2>&1
	[ $? -ne 0 -a $? -ne 23 ] && alerta 160
	chmod 777 /nfs/ibmcom01_prd_tesouraria/safe/safe_in/*
	sleep 1
fi

# Envio de arquivos para LASASCE02

mount -v | grep -i "/smbfs/LASASCE02/ftproot" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  if [ `ls /smbfs/LASASCE02/ftproot/SAIDA/SCE10/* 2>/dev/null | wc -l` -gt 0 ]; then
    /usr/bin/rsync -v --remove-sent-files /smbfs/LASASCE02/ftproot/SAIDA/SCE10/* /LOCAL_STARX/CITIBANCK >>$log 2>&1 
    [ $? -ne 0 -a $? -ne 23 ] && alerta 80
    if [ -d  /LOCAL_STARX/CITIBANCK ]; then
      cd  /LOCAL_STARX/CITIBANCK
      for i in `ls cb* CB* | grep -v "zip$"`; do
        zip -9 -m $i.zip $i
        #rm -f $i
        for arq in `ls CB*`; do
          arq1="`ls ${arq} | dd conv=lcase `"
          mv ${arq} ${arq1}
        done
        chmod 777 $i.zip
      done
    fi
    sleep 1
  fi
else
  alerta 70
fi

mount -v | grep -i "/smbfs/LASASCE02/ftproot" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  if [ `ls /smbfs/LASASCE02/ftproot/SAIDA/SCE11/* 2>/dev/null | wc -l` -gt 0 ]; then
    /usr/bin/rsync -v --remove-sent-files /smbfs/LASASCE02/ftproot/SAIDA/SCE11/* /LOCAL_STARX/CITIBANCK >>$log 2>&1 
    [ $? -ne 0 -a $? -ne 23 ] && alerta 80
    if [ -d  /LOCAL_STARX/CITIBANCK ]; then
      cd  /LOCAL_STARX/CITIBANCK
      for i in `ls  cb* CB* | grep -v "zip$"`; do
        zip -9 -m $i.zip $i
        #rm -f $i
        for arq in `ls CB*`; do
          arq1="`ls ${arq} | dd conv=lcase `"
          mv ${arq} ${arq1}
        done
        chmod 777 $i.zip
      done
    fi
    sleep 1
  fi
else
  alerta 70
fi

mount -v | grep -i "/smbfs/LASASCE02/ftproot" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  if [ `ls /smbfs/LASASCE02/ftproot/SAIDA/SCE12/* 2>/dev/null | wc -l` -gt 0 ]; then
    /usr/bin/rsync -v --remove-sent-files /smbfs/LASASCE02/ftproot/SAIDA/SCE12/* /LOCAL_STARX/CITIBANCK >>$log 2>&1 
    [ $? -ne 0 -a $? -ne 23 ] && alerta 80
    if [ -d  /LOCAL_STARX/CITIBANCK ]; then
      cd  /LOCAL_STARX/CITIBANCK
      for i in `ls cb* CB* | grep -v "zip$"`; do
        zip -9 -m $i.zip $i
        #rm -f $i
        for arq in `ls CB*`; do
          arq1="`ls ${arq} | dd conv=lcase `"
          mv ${arq} ${arq1}
        done
        chmod 777 $i.zip
      done
    fi
    sleep 1
  fi
else
  alerta 70
fi

umount /smbfs/SAFE_FAI/integracao
umount /smbfs/SAFE_FAI_NOVO/integracao
umount /smbfs/LASASCE02/ftproot

pusopo34 "FIM transacao" $log
