#!/bin/bash
VM=$(/usr/sbin/dmidecode -t1 |grep "Manufacturer:" |grep VMware |wc -l)
if [ ${VM} -eq 0 ]; then
	/sbin/lspci -vv |grep SCSI
fi