#!/usr/bin/env bash
<<HEAD
    SCRIPT: cria_md5_evento.sh
    AUTHOR: Agápito Rojas (agapito.rojas@lasa.com.br)
    DESCRIPTION: Script para inserir hash MD5 dos eventos no controle
    VERSION: 1.0 (01/08/2019)
    HISTORY:
HEAD

ev_files="/lasa/pdvs/dados/evcartao.idx /lasa/pdvs/dados/evcartao /lasa/pdvs/dados/evdescto /lasa/pdvs/dados/evdescto.idx /lasa/pdvs/dados/evgeral.idx /lasa/pdvs/dados/evgeral /lasa/pdvs/dados/evsaque /lasa/pdvs/dados/evsaque.idx /lasa/pdvs/dados/rtautrz.idx /lasa/pdvs/dados/rtautrz /lasa/pdvs/dados/rtdedi45 /lasa/pdvs/dados/rtdedi45.idx /lasa/pdvs/dados/RTDCAT45.idx /lasa/pdvs/dados/RTDCDI45.idx /lasa/pdvs/dados/RTDPIT45.idx /lasa/pdvs/dados/RTEVSQ45.idx /lasa/pdvs/dados/RTEVTC45.idx /lasa/pdvs/dados/RTEVTC45 /lasa/pdvs/dados/RTEVSQ45 /lasa/pdvs/dados/RTDPIT45 /lasa/pdvs/dados/RTDCDI45 /lasa/pdvs/dados/RTDCAT45 /lasa/pdvs/dados/evdepit.idx /lasa/pdvs/dados/evdepit /lasa/pdvs/dados/RTTBDI45.idx /lasa/pdvs/dados/RTTBDI45 /lasa/pdvs/dados/RTTBPC45 /lasa/pdvs/dados/RTTBPC45.idx /lasa/pdvs/dados/evtbpc /lasa/pdvs/dados/evtbpc.idx"
db_usr="mon_flash"
db_pwd="monlasa"
evcart_srv="lxlasa12"
ssh_opt="ssh -o ConnectTimeout=15 -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -o StrictHostKeyChecking=no -o LogLevel=ERROR"
yesterday="$(date +%F -d'-1 day')"

f_md5_ev (){
    dtn_host=$1
    su nagios -c "${ssh_opt} rsync@${dtn_host} 'md5sum ${ev_files[@]} |md5sum' |tr -cd '[:alnum:]'"
}

mysql -h ${evcart_srv} -BN -u${db_usr} -p${db_pwd} -e "select num_evento,loja from evento_cartao.arquivo_gerado where data = '${yesterday}' and status = 'enviado';" | \
while read lj_ev; do
    set ${lj_ev}
    ev=$1
    lj=$2
    if [[ -n "${ev}" ]]; then
        ip_lj=$(ver_end ${lj} |cut -f1)
        md5_ev=$(f_md5_ev ${ip_lj})
        if ( grep -w ${md5_ev} /var/www/html/md5sum >/dev/null 2>&1 ); then
            exit 0
        else
            echo "1:${md5_ev}" >>/var/www/html/md5sum
        fi
    fi
done