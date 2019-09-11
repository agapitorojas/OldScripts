#!/bin/bash
<<INTRO

	Script de verificação de parâmetro de boleto ACOM

	Autor: Agápito Rojas (agapito.rojas@lasa.com)
INTRO

if [ -f /DSOP/DTAB/EH_P2K_TOTAL -a ! -f /DSOP/DTAB/EH_HYDRA ]; then
	echo "Loja P2K"
	exit 0
fi

if [ -f /DSOP/DTAB/EH_HYDRA ]; then
	echo "Loja Hydra"
	exit 0
fi

if [ "$(sed -n '108p' /lasa/pdvs/dados/rtpasr30.csi |cut -c16)" == "S" ]; then
	echo "DV ACOM OK"
else
	echo "DV ACOM não definido"
fi