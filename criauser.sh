#!/bin/bash
#

for PTR in 726486 107875 023809 208468 200543; do
	[ ${PTR} = 726486 ] && DESC="Marcilio Cavalcanti de Almeida"
	[ ${PTR} = 107875 ] && DESC="Emilio Hernandez Neto"
	[ ${PTR} = 023809 ] && DESC="Marcia Cristina Aquino"
	[ ${PTR} = 208468 ] && DESC="Maila Fabiana Gomes de Oliveira"
	[ ${PTR} = 200543 ] && DESC="Luanda Teixeira de Lima Costa"

	. /DSOP/DEXE/pusopu16 gessup ${PTR} '${DESC}'
done	