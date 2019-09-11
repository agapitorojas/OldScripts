#!/bin/ash
#
# Script de inventário ESXi
#
CPUDESC=$(vim-cmd hostsvc/hosthardware |awk '/cpuPkg/,/]/' |grep description |cut -d'"' -f2)
CPUGET="esxcli hardware cpu global get"
CPUCORES=$(${CPUGET} |grep "CPU Cores:" |cut -d: -f2 |sed 's/^[ \t]*//g')
CPUTHREADS=$(${CPUGET} |grep "CPU Threads:" |cut -d: -f2 |sed 's/^[ \t]*//g')
DATE=$(date -I)
HOSTNAME=$(hostname)
MEMORY=$(esxcli hardware memory get |grep "Physical Memory:" |cut -d: -f2 |sed 's/^[ \t]*//g')
PLATFORM="esxcli hardware platform get"
PRODUCT=$(${PLATFORM} |grep "Product Name:" |cut -d: -f2 |sed 's/^[ \t]*//g')
VENDOR=$(${PLATFORM} |grep "Vendor Name:" |cut -d: -f2 |sed 's/^[ \t]*//g')
SERIAL=$(${PLATFORM} |grep "Serial Number:" |cut -d: -f2 |sed 's/^[ \t]*//g')
SCSIDEVS="esxcfg-scsidevs -l"
SCSINAME=$(${SCSIDEVS} |grep "Display Name:" |cut -d: -f2 |sed 's/^[ \t]*//g')
SCSISIZE=$(${SCSIDEVS} |grep "Size:" |cut -d: -f2 |sed 's/^[ \t]*//g')
VMVERSION=$(vmware -l)
VMBUILD=$(vmware -v |awk '{print $NF}' |cut -d- -f2)
echo "======================================================================"
echo "${HOSTNAME} ${DATE}"
echo "======================================================================"
echo "===============================SISTEMA================================"
echo -e "Fabricante: ${VENDOR}\nModelo: ${PRODUCT}\nNº de série: ${SERIAL}"
echo "==================================SO=================================="
echo -e "Sistema Operacional: ${VMVERSION}\nBuild: ${VMBUILD}"
echo "======================================================================"
echo "=================================CPU=================================="
echo -e "CPU: ${CPUDESC}\nNúcleos: ${CPUCORES}\nThreads: ${CPUTHREADS}"
echo "======================================================================"
echo "=================================RAM=================================="
echo -e "Total: ${MEMORY}"
echo "======================================================================"
echo "============================ARMAZENAMENTO============================="
echo -e "Dispositivo: ${SCSINAME}\nTamanho: ${SCSISIZE}"
echo "======================================================================"
