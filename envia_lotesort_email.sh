#!/bin/bash

/usr/bin/timeout 20 /bin/mount -t nfs lxlasa11:/lasa/usr/PRODUCAO/COMNC/STATX /mnt/nfs/LXLASA11/ 2>/dev/null

if [ $? -eq 0 ]; then

	PKG=$(/usr/bin/timeout 20 /bin/ls -tr /mnt/nfs/LXLASA11/ARQUIVOS/PROMOLEVPAG/novo_pacote_promocao_levpag.*.tar.bz2 2>/dev/null |tail -1)
	if [ -n "${PKG}" ]; then
		MD5PKG=$(/usr/bin/md5sum ${PKG} 2>/dev/null |awk '{print $1}')
		MD5PREV=$(cat /tmp/novo_pacote_promocao_levpag.md5 2>/dev/null)
		if [ "${MD5PKG}" != "${MD5PREV}" ]; then
			MTIME=$(/usr/bin/stat -c '%y' ${PKG} |awk -F'.' '{print $1}')
			echo "Segue arquivo anexo." |\
			/usr/bin/timeout 20 /bin/mail -a ${PKG} -b agapito.rojas@lasa.com.br -r suporteux-lasa@lasa.com.br -s "Promo Leve e Pague ${MTIME}" suporteux-lasa@lasa.com.br
			[ $? -eq 0 ] && echo "${MD5PKG}" >/tmp/novo_pacote_promocao_levpag.md5
		fi
	fi
fi

/bin/umount /mnt/nfs/LXLASA11 2>/dev/null