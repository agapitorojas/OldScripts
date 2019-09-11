#!/bin/bash
<<INTRO
	Script para cáculo da idade dos discos.
INTRO

if [ "$(/usr/sbin/dmidecode -t1 |grep Manufacturer: |cut -d: -f2 |grep VMware |wc -l)" -gt 0 ]; then
	echo -e "\e[94mLoja virtualizada\e[0m"
	exit 0
fi

DSKAGE(){
	PWONHR=$(/usr/sbin/smartctl -A $1 |grep "Power_On_Hours" |awk '{print $NF}')
	if [ -z "${PWONHR}" ]; then
		echo -e "\e[93m$1: informação não disponível\e[0m"
	else
		[ ${PWONHR} -ge 43800 ] && COLOR="\e[91m"
		[ ${PWONHR} -lt 43800 ] && COLOR="\e[92m"
		if [ ${PWONHR} -ge 8760 ]; then
			YEARS=$(echo "${PWONHR} / 8760" |bc)
			REST1=$(echo "${PWONHR} % 8760" |bc)
			if [ ${REST1} -ge 730 ]; then
				MONTH=$(echo "${REST1} / 730" |bc)
				REST2=$(echo "${REST1} % 730" |bc)
				if [ ${REST2} -ge 24 ]; then
					DAYS=$(echo "${REST2} / 24" |bc)
					REST3=$(echo "${REST2} % 24" |bc)
					if [ ${REST3} -gt 0 ];then
						HOURS="${REST3}"
					fi
				elif [ ${REST2} -lt 24 ]; then
					HOURS="${REST2}"
				fi
			elif [ ${REST1} -lt 730 -a ${REST1} -ge 24 ]; then
				DAYS=$(echo "${REST1} / 24" |bc)
				REST2=$(echo "${REST1} % 24" |bc)
				if [ ${REST2} -gt 0 ]; then
					HOURS="${REST2}"
				fi
			elif [ ${REST1} -lt 24 ]; then
				HOURS="${REST1}"
			fi
		elif [ ${PWONHR} -lt 8760 -a ${PWONHR} -ge 730 ]; then
			MONTH=$(echo "${PWONHR} / 730" |bc)
			REST1=$(echo "${PWONHR} % 730" |bc)
			if [ ${REST1} -ge 24 ]; then
				DAYS=$(echo "${REST1} / 24" |bc)
				REST2=$(echo "${REST1} % 24" |bc)
				if [ ${REST2} -gt 0 ]; then
					HOURS="${REST2}"
				fi
			else HOURS="${REST1}"
			fi
		elif [ ${PWONHR} -lt 730 -a ${PWONHR} -ge 24 ]; then
			DAYS=$(echo "${PWONHR} / 24" |bc)
			REST1=$(echo "${PWONHR} % 24" |bc)
			if [ ${REST1} -gt 0 ]; then
				HOURS="${REST1}"
			fi
		elif [ ${PWONHR} -lt 24 ]; then
			HOURS="${PWONHR}"
		fi
	fi
	[[ -n "${YEARS}" ]] && OUTYEARS="${YEARS} ano(s) "
	[[ -n "${MONTH}" ]] && OUTMONTH="${MONTH} mes(es) "
	[[ -n "${DAYS}"  ]] && OUTDAYS="${DAYS} dia(s) "
	[[ -n "${HOURS}" ]] && OUTHOURS="${HOURS} hora(s)"

	if [ -n "${OUTYEARS}" -o -n "${OUTMONTH}" -o -n "${OUTDAYS}" -o -n "${OUTHOURS}" ]; then
		echo -e "${COLOR}$1: ${OUTYEARS}${OUTMONTH}${OUTDAYS}${OUTHOURS}\e[0m"
	fi
	unset YEARS MONTH DAYS HOURS OUTYEARS OUTMONTH OUTDAYS OUTHOURS
}

DISCOS=($(/sbin/fdisk -l /dev/[hs]d[a-z] 2>/dev/null |grep ^Disk |awk -F"[ :]" '{print $2}'))

for DSK in ${DISCOS[@]}; do
	DSKAGE ${DSK}
done