#!/bin/bash
<<INTRO
  Script de alteração de velocidade de interface de rede.
INTRO


ROUTE=($(/sbin/ip r |grep ^default)) ## Rota padrão
GW=${ROUTE[2]} ## IP do gateway
NIC=${ROUTE[4]} ## Interface padrão

link_test(){
  STATUS=$(/sbin/ethtool $1 |grep "Link detected" |cut -d: -f2 |sed 's/^[ \t]//g')

} 

echo "${NIC} -> ${GW}"

#GW=$(${ROUTE} |awk '{print $2}')
#NIC=$(${ROUTE} |awk '{print $NF}')
