#/bin/bash

mata_processos(){
	for X in $(ps aux |egrep 'sgc73050|sgc73082|sgc73088|pugesc13|wc' |grep -v grep |awk '{print $2}'); do 
		kill -9 ${X} 
	done
}

rm -fv /DSOP/DLOG/SUSOPO_GES013*
mata_processos && echo OK!