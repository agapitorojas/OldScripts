#!/bin/bash
UF=$(sed -n 2p /p2k/bin/logUltimaVenda.log 2>/dev/null |awk '{print $NF}')
[ -z "${UF}" ] && UF=$(awk '(/buscaUF/ && /uf = /) || /UFLOJA =/ || /UF Loja :/ {print $NF}' /p2k/bin/CSIDebugFile.txt |sort -u)
if [ -n "${UF}" ]; then
	case ${UF} in
		AC)
		ln -fs /usr/share/zoneinfo/America/Rio_Branco /etc/localtime && ls -hl /etc/localtime ;;
		AL|SE)
		ln -fs /usr/share/zoneinfo/America/Maceio /etc/localtime && ls -hl /etc/localtime ;;
		AM)
		ln -fs /usr/share/zoneinfo/America/Manaus /etc/localtime && ls -hl /etc/localtime ;;
		AP|PA)
		ln -fs /usr/share/zoneinfo/America/Belem /etc/localtime && ls -hl /etc/localtime ;;
		BA)
		ln -fs /usr/share/zoneinfo/America/Bahia /etc/localtime && ls -hl /etc/localtime ;;
		CE|MA|PB|PI|RN)
		ln -fs /usr/share/zoneinfo/America/Fortaleza /etc/localtime && ls -hl /etc/localtime ;;
		DF|ES|GO|MG|PR|RJ|RS|SC|SP)
		ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && ls -hl /etc/localtime ;;
		MS)
		ln -fs /usr/share/zoneinfo/America/Campo_Grande /etc/localtime && ls -hl /etc/localtime ;;
		MT)
		ln -fs /usr/share/zoneinfo/America/Cuiaba /etc/localtime && ls -hl /etc/localtime ;;
		PE)
		ln -fs /usr/share/zoneinfo/America/Recife /etc/localtime && ls -hl /etc/localtime ;;
		RO)
		ln -fs /usr/share/zoneinfo/America/Porto_Velho /etc/localtime && ls -hl /etc/localtime ;;
		RR)
		ln -fs /usr/share/zoneinfo/America/Boa_Vista /etc/localtime && ls -hl /etc/localtime ;;
		TO)
		ln -fs /usr/share/zoneinfo/America/Araguaina /etc/localtime && ls -hl /etc/localtime ;;
		*)
		echo "${UF}: UF inválida." ;;
	esac
else
	echo "UF não encontrada."
fi