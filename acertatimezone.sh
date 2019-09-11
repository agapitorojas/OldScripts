#!/bin/bash
<<INTRO

  Script para acertar a timezone de loja com base na UF

INTRO

DBSRV="db_flash" ## Servidor Flash
USRDB="rfloja" ## Usuário de consulta
PWDDB="lojarf04" ## Senha do usuário de consulta
LOJA=$(hostname |cut -d_ -f2-)
[ ${LOJA} -lt 1000 ] && LOJA=L${LOJA}
SLEEP=$(echo "${RANDOM} % 6" |bc)

host ${DBSRV} >/dev/null 2>&1
if [ "$?" -eq "0" ]; then
  /usr/bin/nc -zw3 ${DBSRV} 3306 >/dev/null 2>&1
  if [ "$?" -eq "0" ]; then
    sleep ${SLEEP}
    UF=$(mysql --connect_timeout=5 -h${DBSRV} -BNp -u${USRDB} -p${PWDDB} -e "select uf from lasa.info_lojas where loja = '${LOJA}';" 2>/dev/null)
    if [[ -z ${UF} ]]; then
      echo "UF não encontrada!"
      exit 3
    else
      case ${UF} in
        AC)
          ZONE="America/Rio_Branco" ;;
        AL|SE)
          ZONE="America/Maceio" ;;
        AM)
          ZONE="America/Manaus" ;;
        AP|PA)
          ZONE="America/Belem" ;;
        BA)
          ZONE="America/Bahia" ;;
        CE|MA|PB|PI|RN)
          ZONE="America/Fortaleza" ;;
        DF|ES|GO|MG|PR|RJ|RS|SC|SP)
          ZONE="America/Sao_Paulo" ;;
        MS)
          ZONE="America/Campo_Grande" ;;
        MT)
          ZONE="America/Cuiaba" ;;
        PE)
          ZONE="America/Recife" ;;
        RO)
          ZONE="America/Porto_Velho" ;;
        RR)
          ZONE="America/Boa_Vista" ;;
        TO)
          ZONE="America/Araguaina" ;;
        *)
          echo -e "\e[91m${UF}: UF inválida.\e[0m" ;;
      esac
      if [[ -n ${ZONE} ]]; then
        ln -fs /usr/share/zoneinfo/${ZONE} /etc/localtime && echo -e "export TZ=${ZONE}\nexport UF=${UF}" >/etc/profile.d/tz.sh && echo -e "\e[92m${UF}: TZ='${ZONE}' utilizada.\e[0m"
      fi
    fi
  else
    echo "Erro ao acessar o banco no \"${DBSRV}\"."
    exit 2
  fi
else
  echo "Erro ao resolver \"${DBSRV}\"."
  exit 1
fi