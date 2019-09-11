#### nova versão
# 12/10/2016  Motivo - Interceptar os arquivos de tesouraria da loja 0654 P2K, pra que sejam enviados para do Hydra. Uma vez mergeados os movimentos do P2K e Hydra serão consumidos no SFTP e enviados a Tesouraria 
# Aplicação IBMPI03 - Produção e IBMPI02 - hOMOLOGAÇÃO 
# Creator: Pita - Equipe de Sistema de Lojas
####

##
## Declaracao de variaveis
##

###  Variaveis de ambiente existem diferencas entre o HML e PRODUCAO

arqseq="*.*" 
dirdestsftp="/home/hydra/get/teshibrida/aprocessar/"                    ## PRD Diretorio do servidor SFTP (lxlasa11) de destino dos arquivos do P2K para o Hydra.
dirinputsftp="/home/hydra/put/teshibrida/integrahibrida/"               ## PRD Diretorio do servidor SFTP (lxlasa11) de origem dos arquivos do Hydra a serem enviados para a Tesouraria e o PROSEGUR.   
userhydra="hydra"    ## Este usuario SOMENTE em ProduÃ§Ã£o                     

###
arqtodos="*.*"
arqseqgz=".gz"
dirinic="/RSYNC/ARQUIVOS/"                                                 ## Diretorio origem dos arquivos do P2K, existe um processo p2k.acesso.ex.sh que busca as informaÃ§oes no fileserver P2K 
dirinput="/RSYNC/ARQUIVOS/HYDRA/APROCESSAR/"                               ## Diretorio de transiÃ§Ã£o dos arquivos a serem transmitidos para o HYdra 
dirbkp="/RSYNC/ARQUIVOS/HYDRA/BKPMOVTP2K/"                                 ## Diretorio de backup doa arquivos de movimento P2K enviados para o Hydra no servidor SFTP 
dirdesttes="/RSYNC/TESOURARIA/"                                            ## Diretorio de destino dos Arquivos de movimento de tesouraria arquivos : LFIN/LRIN/LOUT/LVDEP/LCOL
dirdesttester="/RSYNC/PROSEGUR/"                                           ## Diretorio de destino doa Arquivos de movimento de tesouraria arquivos: TERCEIRIZADA COLET
dirlog="/RSYNC/ARQUIVOS/HYDRA/LOG/"                                        ## Diretorio de gravaÃ§Ã£o dos logs de processamento
dirbkpenvio="/RSYNC/ARQUIVOS/HYDRA/INTEGRADOS/"                            ## Diretorio de backuo dos arquivos intrgrados com a tesouraria
arqlogenvio="logtransmissaohydra_tesouraria".`date +"%Y%m%d"` 
arqlog="represahydraexecucoes.log".`date +"%Y%m%d"` 
arqlogprisma="movlogprismatesouraria.log".`date +"%Y%m%d"` 
arqlogp2k="movlogp2ktesouraria.log".`date +"%Y%m%d"` 
arqlogtes="transmissao_pi_hydra.log".`date +"%Y%m%d"`

#
# Funcoes
#
imp_cabec ()
{
	echo $out
	echo "*************************************************************************************************************************************" >> ${dirlog}${arqlog}
	echo "**** script ==> represahydra.ex.sh        - Lojas Hydra - Hibridas                                                             ******" >> ${dirlog}${arqlog}
	echo "**** inicio em ==>" $(date)  >> ${dirlog}${arqlog}
	echo "****                                      copia diaria dos arquivos de tesouraria do hydra                                     ******" >> ${dirlog}${arqlog}
	echo "************************************************************************************  ***********************************************" >> ${dirlog}${arqlog}
}
intecepta_arquivos_p2k () 
{

for loja in 0954
do

echo "LOJA - $loja"

## Arquivos do P2k disponiveis para serem recebidos /RSYNC/P2K/LJ${loja}/Exportacao/


	ls /RSYNC/P2K/LJ${loja}/Exportacao/*.${loja} | grep -E "lfin|lrin|lout|tes|LVDEP" | xargs -I {} cp {} ${dirinput} 	
	echo "/RSYNC/P2K/LJ${loja}/Exportacao/*.${loja} | grep -E 'lfin|lrin|lout|tes|LVDEP' | xargs -I {} cp {} ${dirinput}"
## Trata LCOL
testa_cond=`ls -l /RSYNC/ARQUIVOS/LCOL/*.${loja} |wc -l` 
echo "LCOL - $testa_cond"
  if [ $testa_cond -ge 1 ]
  then 
	echo 'rsync --quiet --timeout=60 --chmod go+rw -p -e /RSYNC/ARQUIVOS/LCOL/*.${loja} ${dirinput}'
     rsync --quiet --timeout=60 --chmod go+rw -p -e /RSYNC/ARQUIVOS/LCOL/*.${loja} ${dirinput}
  fi
## Trata Log	
testa_cond=`ls -l ${dirinput}*.${loja} |wc -l`
echo "TRATA LOG - $testa_cond"
	if [ $testa_cond -ge 1 ]
	then   	
       ls ${dirinput}*.${loja} >> ${dirlog}${arqlogp2k}
	fi		
	
done	
}



integra_hydra_arquivos () 
{
testa_cond=`ls ${dirinput}${arqseq} |wc -l` 
    if [ $testa_cond -ge 1 ]
    then
       ls ${dirinput}${arqseq} >> ${dirlog}${arqlogtes}
       rsync ${dirinput}${arqseq} ${dirbkp}
       rsync --quiet --timeout=60 --remove-source-files --chmod go+rw -p -e ssh ${dirinput}${arqseq} ${userhydra}@52.31.152.165:${dirdestsftp}  >/dev/null 2>&1  ## Validado
       teste_arq=1
    fi
}
imp_rodape ()
{
    echo "****                                                                                                                  ***************" >> ${dirlog}${arqlog}
    echo "**** termino em ==>" $(date) >> ${dirlog}${arqlog}
    echo "*************************************************************************************************************************************" >> ${dirlog}${arqlog}

    chmod 777 ${dirlog}${arqlog}

}
processa_arqseq ()
{

    testa_cond=`ls ${dirbkp}${arqseq} |wc -l` 
    if [ $testa_cond -ge 1 ]
    then
       echo " " >> ${dirlog}${arqlog}
       `ls ${dirbkp}${arqseq} |wc -l` >> ${dirlog}${arqlog}
	   gzip --force ${dirbkp}${arqseq}
       echo " " >> ${dirlog}${arqlog}  
	else
	   echo " " >> ${dirlog}${arqlog}
       echo " Nao foram encontrados arquivos para compactar !!!! " >> ${dirlog}${arqlog}
       echo " " >> ${dirlog}${arqlog}     
    fi

}
transmite_tesouraria ()
{
   teste_bkp=0
  ## Tesouraria Terceirizada	Arquivos COLET
	testa_tes=`ssh ${userhydra}@52.31.152.165 ls ${dirinputsftp}${arqseqtester} |wc -l` 
    if [ $testa_tes -ge 1 ]
    then 
	  `ssh ${userhydra}@52.31.152.165 ls -l  ${dirinputsftp}${arqseqtester} >> ${dirlog}${arqlogenvio}`
	  rsync ${userhydra}@52.31.152.165:${dirinputsftp}${arqseqtester} ${dirbkpenvio}
      rsync -rlptgoqz --omit-dir-times --remove-sent-files --timeout=60 --chmod go+rw -p -e ssh ${userhydra}@52.31.152.165:${dirinputsftp}${arqseqtester} ${dirdesttester} >/dev/null 2>&1    
  	  teste_bkp=1
	fi
  ## Tesouraria Normal LFIN / LRIN / LOUT / LVDEP / TES
	testa_tes=`ssh ${userhydra}@52.31.152.165 ls ${dirinputsftp}${arqseq} |wc -l`  
	if [ $testa_tes -ge 1 ]
    then 
	   `ssh ${userhydra}@52.31.152.165 ls -l  ${dirinputsftp}${arqseq} >> ${dirlog}${arqlogenvio}`
       rsync ${userhydra}@52.31.152.165:${dirinputsftp}${arqseq} ${dirbkpenvio}
	   rsync -rlptgoqz --omit-dir-times --remove-sent-files --timeout=60 --chmod go+rw -p -e ssh ${userhydra}@52.31.152.165:${dirinputsftp}${arqseq} ${dirdesttes} >/dev/null 2>&1 	  
	   teste_bkp=1
	fi
  ## Compata arquivos transmitidos para a Tesouraria e o PROSEGUR
    if [ $teste_bkp -ge 1 ]
    then 
	   gzip --force ${dirbkpenvio}${arqseq}
	fi
}

# REALIZA O TRANSPORTE DOS ARQUIVOS DO REGISTRADO E COLETADO DA TESOURARIA HYDRA PARA O LEGADO

	rsync -rlptgoqz --omit-dir-times --remove-sent-files --timeout=60 /RSYNC/TESOURARIA/HYDRA/*COLET*.* /RSYNC/PROSEGUR/  --log-file=/DSOP/LOG/PROSEGUR_HYDRA_CONT.log 

	rsync -rlptgoqz --omit-dir-times --exclude 'COLET*' --remove-sent-files --timeout=60 /RSYNC/TESOURARIA/HYDRA/*.* /RSYNC/TESOURARIA/  --log-file=/DSOP/LOG/TES_HYDRA_CONT.log 

##########################
##
##   Corpo do Script
##
##########################

imp_cabec	  
intecepta_arquivos_p2k 
integra_hydra_arquivos
processa_arqseq  
arqseqtester="*COLET*.*"
transmite_tesouraria
imp_rodape