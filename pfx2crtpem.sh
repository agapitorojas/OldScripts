#!/bin/bash
<<INTRO
	Script para conversão do certicado PFX para CRT e PEM
	Uso:

	./pfx2crtpem.sh /caminho/para/arquivo.pfx
	Cria arquivos .crt e .pem no diretório atual
	Adaptado de: https://gist.github.com/ericharth/8334664
INTRO

PFX="$1"

if [ ! -f "${PFX}" ]; then
	echo "Arquivo PFX não encontrado em '${PFX}'."
	exit 1
fi

crtname=`basename ${PFX%.*}`
domaincacrtpath=`mktemp`
domaincrtpath=`mktemp`
fullcrtpath=`mktemp`
keypath=`mktemp`
passfilepath=`mktemp`
read -s -p "PFX password: " pfxpass
echo -n $pfxpass > $passfilepath

echo "Criando arquivo .CRT."
openssl pkcs12 -in $PFX -out $domaincacrtpath -nodes -nokeys -cacerts -passin file:$passfilepath
openssl pkcs12 -in $PFX -out $domaincrtpath -nokeys -clcerts -passin file:$passfilepath
cat $domaincrtpath $domaincacrtpath > $fullcrtpath
rm $domaincrtpath $domaincacrtpath

echo "Criando arquivo .KEY."
read -s -p "CRT password: " crtpass
openssl pkcs12 -in $PFX -nocerts -passin file:$passfilepath -passout pass:${crtpass} \
| openssl rsa -out $keypath -passin pass:${crtpass}

rm $passfilepath

mv $fullcrtpath ./${crtname}.pem
mv $keypath ./${crtname}.key

ls -l ${crtname}.pem ${crtname}.key