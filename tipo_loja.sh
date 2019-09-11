#!/bin/bash
<<INTRO
	Script de verificação de tipo de loja

	Autor: Agápito Rojas (agapito.rojas@lasa.com)
INTRO

if [ -f /DSOP/DTAB/EH_P2K_TOTAL -a ! -f /DSOP/DTAB/EH_HYDRA ]; then
	echo "Loja P2K"
	exit 0
elif [ -f /DSOP/DTAB/EH_HYDRA ]; then
	echo "Loja Hydra"
	exit 0
else
	echo "Loja Prisma"
fi