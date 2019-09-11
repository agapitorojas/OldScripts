export TERM=vt320
. /DSOP/DEXE/pusopo12 >/dev/null 2>&1
host=$EXEC_SCRIPTS
set -x
user=loja
database=pdv
PWDPDV=$PWDLOJA

#
# carga de dados de loja P2K
#

/DSOP/SCRIPTS/carga_pdv_p2k.sh

#
#

dir="/lasa/usr/PRODUCAO/COMNC/STARX/PDV"

cd $dir

>SQL_pdv_totais
>DADOS_pdv_totais

CONTADOR=1

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

for arq in `ls pdv_totais_???*.mysql`
do
	[ ! -s $arq ] && continue
	loja=`echo $arq | cut -d"_" -f3 | cut -d. -f1`
	echo "delete from pdv_totais where loja=${loja};" >>SQL_pdv_totais
	[ $loja -lt 1000 ] && loja=0${loja}
	echo "delete from pdv_totais where loja='${loja}';" >>SQL_pdv_totais
	cat $arq >>DADOS_pdv_totais

done

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

#
# limpa tabelas
#
echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} -p${PWDPDV} -D ${database} <<FIM
delete from consolida_info_pdvs where data < subdate(current_date(), interval 365 day);
delete from versao_pdvs where data_coleta < subdate(current_date(), interval 365 day);
delete from operacao_pdv where data_coleta < subdate(current_date(), interval 365 day);
delete from venda_pdv where data_coleta < subdate(current_date(), interval 365 day);
delete from redz_pdv where data_coleta < subdate(current_date(), interval 365 day);
delete from atividade_pdvs where data < subdate(current_date(), interval 365 day);
delete from inventario_pdv where data < subdate(current_date(), interval 365 day);
delete from operacao_pdv where data < subdate(current_date(), interval 365 day);
delete from totaliza_operacao where data < subdate(current_date(), interval 365 day);
delete from totaliza_redz where data < subdate(current_date(), interval 365 day);
delete from totaliza_venda where data < subdate(current_date(), interval 365 day);
\quit;
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

#


echo "load data local infile \"$dir/DADOS_pdv_totais\" into table pdv_totais fields terminated by ':';" >>SQL_pdv_totais
echo "update pdv_totais set loja=lpad(loja,4,0);" >>SQL_pdv_totais
echo "update INFOPDV_P2K_pdv_totais a,pdv_totais b set a.total=(a.total + b.total),a.30dias=(a.30dias + b.30dias),a.3060dias=(a.3060dias + b.3060dias),a.mais60dias=(a.mais60dias + b.mais60dias) where a.loja=b.loja;" >>SQL_pdv_totais
echo "replace into pdv_totais (select * from INFOPDV_P2K_pdv_totais);" >>SQL_pdv_totais
echo "delete from INFOPDV_P2K_pdv_totais;" >>SQL_pdv_totais

mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} <SQL_pdv_totais

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

rm -f SQL_pdv_totais DADOS_pdv_totais


#
#

find . -name "inventario_pdv.???*.*.mysql" >lista_invent.txt
cat inventario_pdv.???*.*.mysql >inventario_TUDO.mysql
echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} <<FIM
drop table if exists TMPinventario_pdv;
create table TMPinventario_pdv like inventario_pdv;
load data local infile "$dir/inventario_TUDO.mysql" into table TMPinventario_pdv fields terminated by ':'; 
update TMPinventario_pdv set loja=lpad(loja,4,0);
insert ignore into inventario_pdv (select * from TMPinventario_pdv);
drop table if exists TMPinventario_pdv;
\quit;
FIM
if [ $? -eq 0 ]
then
	for arqrem in `cat lista_invent.txt`
	do
		rm -f $arqrem
	done
fi

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

rm -f inventario_TUDO.mysql

#
#
#

cat pdv_relat_???*.mysql >pdv_relat_TUDO.mysql
mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} <<FIM
drop table if exists TMPversao_pdvs;
create table TMPversao_pdvs like versao_pdvs;
load data local infile "$dir/pdv_relat_TUDO.mysql" into table TMPversao_pdvs fields terminated by ':'; 
update TMPversao_pdvs set loja=lpad(loja,4,0);
replace into versao_pdvs (select * from TMPversao_pdvs);
update versao_pdvs set campo1=concat(loja,num_pdv);
drop table if exists TMPversao_pdvs;
\quit;
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

cat NApdv_relat_???*.mysql >NApdv_relat_TUDO.mysql
mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} <<FIM
drop table if exists TMPversao_pdvs;
create table TMPversao_pdvs like versao_pdvs;
load data local infile "$dir/NApdv_relat_TUDO.mysql" into table TMPversao_pdvs fields terminated by ':'; 
update TMPversao_pdvs set loja=lpad(loja,4,0);
delete from TMPversao_pdvs where concat(loja,num_pdv) in (select concat(loja,num_pdv) from versao_pdvs);
insert into versao_pdvs (select * from TMPversao_pdvs);
drop table if exists TMPversao_pdvs;
\quit;
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

#
#
#

echo "delete from venda_pdv where data < subdate(current_date(),interval 2 month);" >/tmp/insert_venda.$$

find . -name "insert_venda.???*.*.mysql" >lista_venda.txt
cat insert_venda.???*.*.mysql >>/tmp/insert_venda.$$

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} </tmp/insert_venda.$$
if [ $? -eq 0 ]
then
	for arqrem in `cat lista_venda.txt`
	do
		rm -f $arqrem
	done
fi
rm -f /tmp/insert_venda.$$

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`



#
#
#

echo "delete from operacao_pdv where data < subdate(current_date(),interval 2 month);" >/tmp/insert_operacao.$$

find . -name "insert_operacao.???*.*.mysql" >lista_operacao.txt
cat insert_operacao.???*.*.mysql >>/tmp/insert_operacao.$$

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} </tmp/insert_operacao.$$
if [ $? -eq 0 ]
then
	for arqrem in `cat lista_operacao.txt`
	do
		rm -f $arqrem
	done
fi
rm -f /tmp/insert_operacao.$$

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

#
#
#

echo "delete from redz_pdv where data < subdate(current_date(),interval 2 month);" >/tmp/insert_redZ.$$

find . -name "insert_redZ.???*.*.mysql" >lista_redZ.txt
cat insert_redZ.???*.*.mysql | grep -v ",.," >>/tmp/insert_redZ.$$

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} </tmp/insert_redZ.$$
if [ $? -eq 0 ]
then
	for arqrem in `cat lista_redZ.txt`
	do
		rm -f $arqrem
	done
fi
rm -f /tmp/insert_redZ.$$

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} <<FIM
call calcula_expira_em();
call ajusta_memoria();
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

#
#

mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} <<FIM
delete from pdv_totais where data_coleta > current_date();
delete FROM versao_pdvs where data_utilizacao > current_date() or data_coleta > current_date();
delete FROM venda_pdv where data_coleta > current_date() or data > current_date();
delete FROM operacao_pdv where data_coleta > current_date() or data > current_date();
delete FROM redz_pdv where data_coleta > current_date() or data > current_date();
\quit;
FIM
#
# consolida totais de pdvs
#

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
delete from consolida_info_pdvs;
delete from totaliza_operacao;
delete from totaliza_venda;
delete from totaliza_redz;
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
insert into totaliza_operacao (select loja,data,count(*) from
operacao_pdv group by loja,data);
insert into totaliza_venda (select loja,data,count(*) from
venda_pdv group by loja,data);
insert into totaliza_redz (select loja,data,count(*) from
redz_pdv group by loja,data);
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
replace into consolida_info_pdvs (select loja,data,0,0,0,0 from totaliza_operacao);
replace into consolida_info_pdvs (select loja,data,0,0,0,0 from totaliza_venda);
replace into consolida_info_pdvs (select loja,data,0,0,0,0 from totaliza_redz);
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
update consolida_info_pdvs a,totaliza_operacao b
set a.tot_operacao=b.total where a.loja=b.loja and
a.data=b.data;
update consolida_info_pdvs a,totaliza_venda b
set a.tot_venda=b.total where a.loja=b.loja and
a.data=b.data;
update consolida_info_pdvs a,totaliza_redz b
set a.tot_redz=b.total where a.loja=b.loja and
a.data=b.data;
update consolida_info_pdvs a,tab_total_pdvs b
set a.total_pdvs=b.qtde where a.loja=b.loja;
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
insert ignore into tab_total_pdvs (select lpad(loja,4,'0'),0 from lasa.lojas);
delete from atividade_pdvs;
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
replace into atividade_pdvs (select loja,pdv,data,serie,'2','2','2' from operacao_pdv);
replace into atividade_pdvs (select loja,pdv,data,serie,'2','2','2' from venda_pdv);
replace into atividade_pdvs (select loja,pdv,data,serie,'2','2','2' from redz_pdv);
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
update atividade_pdvs a,operacao_pdv b
set a.com_operacao='1' where a.loja=b.loja and a.pdv=b.pdv and
a.data=b.data;
update atividade_pdvs a,venda_pdv b
set a.com_venda='1' where a.loja=b.loja and a.pdv=b.pdv and
a.data=b.data;
update atividade_pdvs a,redz_pdv b
set a.com_redz='1' where a.loja=b.loja and a.pdv=b.pdv and
a.data=b.data;
update versao_pdvs a,atividade_pdvs b set a.serial=b.serie where a.serial=''
and a.loja=b.loja and a.num_pdv=b.pdv and a.data_utilizacao=b.data;
update versao_pdvs set model_impr='FS600' where serial like 'DR02%';
update versao_pdvs set model_impr='FS700H' where serial like 'DR05%';
\quit;
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

#
# 
#

>/tmp/carga_validade_mf.$$

>/tmp/TMPcarga_validade_mf2.$$

EXCLUI=`mysql -N -B --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} -e "SELECT '^',loja,':',pdv,':' from pdvs_excluidos" | tr -d "\t" | tr -s "\n" "|"`	

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

mysql -N -B --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} -e "select * from (SELECT loja,pdv,serie,reducoes,data,data_coleta,model_impr,expira_em FROM redz_pdv where expira_em >= current_date() order by data desc) a group by concat(a.loja,a.pdv);" | tr -s "\t" ":" >/tmp/TMPcarga_validade_mf2.$$

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

if [ "$EXCLUI" != "" ]
then
	grep -vE "${EXCLUI}gggg|^hos" /tmp/TMPcarga_validade_mf2.$$  >>/tmp/carga_validade_mf.$$
else
	grep -v "^hos" /tmp/TMPcarga_validade_mf2.$$  >>/tmp/carga_validade_mf.$$
fi
	
rm -f /tmp/TMPcarga_validade_mf2.*


mysql -N -B --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
drop table if exists TMPvalidade_memoria_fiscal;
create table TMPvalidade_memoria_fiscal like MODELO_validade_memoria_fiscal;
load data local infile "/tmp/carga_validade_mf.$$" into table TMPvalidade_memoria_fiscal fields terminated by ":";
update TMPvalidade_memoria_fiscal set loja=lpad(loja,4,0);
drop table if exists validade_memoria_fiscal;
rename table TMPvalidade_memoria_fiscal to validade_memoria_fiscal;
\quit;
FIM


echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`



#

#mysql -N -B --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} -e "SELECT loja,':',pdv,':',serie,':',reducoes,':',data,':',data_coleta,':',model_impr,':',min(expira_em) FROM redz_pdv where expira_em >= current_date() and (concat(loja,pdv) not in (select concat(loja,pdv) from pdvs_excluidos)) group by loja;" | tr -d "\t" >/tmp/carga_validade_mf.$$

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

#mysql -N -B --quick --user=${user} -h ${host} --local-infile -p${PWDPDV} ${database} <<FIM
#drop table if exists TMPvalidade_memoria_fiscal;
#create table TMPvalidade_memoria_fiscal like MODELO_validade_memoria_fiscal;
#load data local infile "/tmp/carga_validade_mf.$$" into table TMPvalidade_memoria_fiscal fields terminated by ":";
#drop table if exists validade_memoria_fiscal;
#rename table TMPvalidade_memoria_fiscal to validade_memoria_fiscal;
#\quit;
#FIM


rm -f /tmp/carga_validade_mf.$$

#
#

cat pdv_relat_???*.mysql | cut -d: -f2 | sort | uniq >versoes.txt
mysql --quick --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} <<FIM
delete from versoes;
load data local infile "$dir/versoes.txt" into table versoes;
\quit;
FIM

echo "TEMPO $CONTADOR `date`" 
CONTADOR=`expr $CONTADOR + 1`

#echo "1:sergio.marques,jorge.cassetti,wagner.prado" >/tmp/email.$$
#echo "2:Impressora termica com memoria de fita menor que 11%" >>/tmp/email.$$
#mysql --user=${user} -h ${host} --local-infile=1 -p${PWDPDV} ${database} -e "SELECT loja,versao,num_pdv,serial,memoria_fita,data_utilizacao FROM versao_pdvs where tipo_impressora='termica' and memoria_fita <=11" | tr -d "|" | tr -d "\+" >>/tmp/email.$$

#email_lasa /tmp/email.$$

