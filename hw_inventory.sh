#!/bin/bash
<<INTRO
	PROGRAMA: hw_inventory.sh
	AUTOR: Agápito Rojas
	Descrição: Script de geração de inventário de Hardware
INTRO

DMI="/usr/sbin/dmidecode"
FDISK="/sbin/fdisk"
ARCH=$(uname -m)
CPUCORES=$(grep "^processor" /proc/cpuinfo |wc -l)
CPUMODEL=$(cat /proc/cpuinfo |grep 'model name' |uniq |cut -d: -f2 |sed 's/^ //')
CPUSOCKS=$(grep "physical id" /proc/cpuinfo |sort |uniq |wc -l)
CPUSPCUR=$(${DMI} -t4 |grep "Current Speed" |cut -d: -f2 |sed 's/^ //' |uniq |grep -v Unknow)
CPUSPMAX=$(${DMI} -t4 |grep "Max Speed" |cut -d: -f2 |sed 's/^ //' |uniq |grep -v Unknow)
DATE=$(date)
DIST=$(lsb_release -d |cut -f2)
DISCOS=$(${FDISK} -l /dev/{h,s}d[a-z] |grep Disk |cut -d: -f1 |awk '{print $2}')
HOST=$(hostname)
KERN=$(uname -r)
MANUFAC=$(${DMI} -t1 |grep Manufacturer: |cut -d: -f2 |sed 's/^ //')
MEMDEVS=$(${DMI} -t17 |grep -v ^Handle |sed -n '/Memory Device/,$p')
MEMFREE=$(free -m |grep Mem |awk '{print $4}')
MEMMAX=$(${DMI} -t16 |grep "Maximum Capacity" |cut -d: -f2 |sed 's/^ //')
MEMSWAP=$(free -m |grep Swap |awk '{print $2}')
MEMSWPU=$(free -m |grep Swap |awk '{print $3}')
MEMTOT=$(free -m |grep Mem |awk '{print $2}')
MEMUSE=$(free -m |grep Mem |awk '{print $3}')
MODEL=$(${DMI} -t1 |grep "Product Name" |cut -d: -f2 |sed 's/^ //')
PROG=$(basename $0 |sed 's/.sh//g')
SN=$(${DMI} -t1 |grep "Serial Number" |cut -d: -f2 |sed 's/^ //')

echo '=========================================================================='
echo "${HOST} - ${DATE}"
echo '=========================================================================='
echo '=================================SISTEMA=================================='
echo "Fabricante:  ${MANUFAC}"
echo "Modelo:      ${MODEL}"
echo "Nº de série: ${SN}"
echo '=========================================================================='
echo '====================================SO===================================='
echo "Distribuição: ${DIST}"
echo "Arquitetura:  ${ARCH}"
echo "Kernel:       ${KERN}"
echo '===============================PROCESSADOR================================'
echo "Modelo:      ${CPUMODEL}"
echo "CPU's:       ${CPUSOCKS}"
echo "Núcleos:     ${CPUCORES}"
echo "Freq. atual: ${CPUSPCUR}"
echo "Freq. máx.:  ${CPUSPMAX}"
echo '=========================================================================='
echo '=================================MEMÓRIAS================================='
echo "Total: ${MEMTOT} MB"
echo "Usado: ${MEMUSE} MB"
echo "Livre: ${MEMFREE} MB"
echo "Swap:  ${MEMSWAP} MB (${MEMSWPU} MB usado)"
echo "Máx:   ${MEMMAX}"
if [ "${MANUFAC}" != "VMware, Inc." ]; then
  echo
  echo  "${MEMDEVS}"
  echo '=========================================================================='
  else
    echo '=========================================================================='
fi
echo '==================================DISCOS=================================='
for DSK in ${DISCOS}; do
  ${FDISK} -l ${DSK} 2>/dev/null
  smartctl -iA ${DSK} 2>/dev/null
done