#!/bin/bash

rm -fv /lasa1/pdvs/dados/GCHIST10*

for PID in $(ps -ef |egrep 'pugesc13|sgc73082|sgc73088' |grep -v grep |awk '{print $2}'); do
	
	kill -9 ${PID}

done	
