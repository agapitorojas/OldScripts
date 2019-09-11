#!/bin/sh

ETH_NIC (){
	AUTONEG="$(ethtool $1 |grep 'Auto-negotiation:')"
	DUPLEX="$(ethtool $1 |grep 'Duplex:')"
	SPEED="$(ethtool $1 |grep 'Speed:')"

	echo "$1 ${SPEED} ${DUPLEX} ${AUTONEG}"
}

for NIC_UP in $(esxcfg-nics -l |grep ^vmnic |grep Up |awk '{print $1}'); do
	ETH_NIC ${NIC_UP}
done