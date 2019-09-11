#!/bin/bash
#
#
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1
DATA=`date '+%Y%m%d - %H:%M'` 
DISCOS=`/sbin/fdisk -l /dev/{h,s}d{a,b,c,d} |grep Disk |cut -d: -f1 |awk '{print $2}'`
LOG=/DSOP/DLOG/estendelasa.log

### Testa nº de discos ###
if [ `fdisk -l /dev/{h,s}d{a,b,c,d} |grep Disk |cut -d: -f1 |awk '{print $2}' |wc -l` -gt 2 ]; then
	echo "Loja com mais de 2 discos."
	exit

elif [ `fdisk -l /dev/{h,s}d{a,b,c,d} |grep Disk |cut -d: -f1 |awk '{print $2}' |wc -l` -eq 1 ]; then
	echo "Loja com menos de 2 discos."
	exit
fi

### Testa a existência do /EXTRA ###
if [ `mount -v |grep EXTRA |wc -l` -eq 1 ]; then
	echo "Loja ainda com /EXTRA. Execute o 'recria_fs_p2k.sh'."
	exit
fi	

### Testa tamanho do /lasa ###
if [ `lvdisplay /dev/vg01/lvlasa |grep 'LV Size' |awk '{print $3}' |cut -d. -f1` -gt 7 ]; then
	echo "Volume do /lasa já extendido."
	exit
fi

cria_particao (){
	### Testa o nº de partições no disco ###
	if [ `fdisk -l $1 |grep ^$1 |wc -l` -eq 8 -a \
	`fdisk -l $1 |tail -1 |awk '{print $3}'` -eq 7108 ]; then
		echo "Criando partição no disco $1."
		sleep 2
		echo "n
		7109
		7595
		t
		9
		fd
		w
		" |fdisk $1
		partprobe 2>/dev/null
	
	elif [ `fdisk -l $1 |grep ^$1 |wc -l` -eq 9 -a \
		`fdisk -l $1 |tail -1 |awk '{print $3}'` -eq 7595 ]; then
		echo "Disco $1 já possui 9 partições."
	
	elif [ `fdisk -l $1 |grep ^$1 |wc -l` -lt 8 ]; then
		echo "Disco $1 com menos de 8 partições."
		exit
	
	else
		echo "Erro na criação da partição no disco $1."
		exit
	fi		
}

cria_md7 (){
	### Cria MD7 caso não exista ###
	if [ `cat /proc/mdstat |grep md7 |wc -l` -eq 0 ]; then
		DSKONE=`echo $DISCOS |cut -d' ' -f1 |sed 's/$/9/g'`
		DSKTWO=`echo $DISCOS |cut -d' ' -f2 |sed 's/$/9/g'`
		mdadm -C /dev/md7 -l1 -n2 ${DSKONE} ${DSKTWO}
	elif [  `cat /proc/mdstat |grep md7 |wc -l` -eq 1 -a \
		`pvdisplay /dev/md7 |grep VG Name 2>/dev/null |wc -l` -eq 0 ]; then
		echo "Array MD7 já pronto"
	else
		echo "Já exite MD7 em uso."
		exit
	fi		
}

echo "## Início - ${DATA} ##" >>${LOG}
echo >>${LOG}

for DSK in ${DISCOS}; do
	cria_particao ${DSK} 2>>${LOG}
done

cria_md7 2>>${LOG}

pvcreate /dev/md7 2>>${LOG}

vgextend vg01 /dev/md7 2>>${LOG}

if [ `uname -r |cut -c1-3` = "2.6" ]; then
	lvextend -l+100%FREE /dev/vg01/lvlasa 2>>${LOG} && resize2fs /dev/vg01/lvlasa 2>>${LOG}
elif [ `uname -r |cut -c1-3` = "2.4" ]; then
	VGFREE=`vgdisplay /dev/vg01 |grep ^Free |cut -d/ -f3 |awk '{print $1}'`
	lvextend -L +${VGFREE}G /dev/vg01/lvlasa 2>>${LOG} && echo "Desmonte o /lasa para fazer o 'resize2fs -f'."
fi
	
TAMFIM=`lvdisplay /dev/vg01/lvlasa |grep "LV Size" |awk '{print $3,$4}'`

echo "Tamanho /lasa: ${TAMFIM}"

echo "FIM"
echo >>${LOG} 
echo "## FIM - ${DATA} ##" >>${LOG}
