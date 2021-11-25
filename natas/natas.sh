#!/bin/bash

vault="$(pwd)/vault.txt"

if [ "$1" != "" ];
then
	wargame=$1
else
	wargame=$(basename $(pwd))
fi

if [ "$2" != "" ];
then
	level=$2
	if [ "$3" != "" ];
	then
		SSHPASS=$3
	else
		SSHPASS=$(grep $wargame$level $vault | awk '{print $2}')
	fi
else
	len=$(expr length $wargame)
	level=$(awk -v len="$len" '{print substr($1,len+1)}' $vault | tail -n 1)
	SSHPASS=$(awk '{print $2}' $vault | tail -n 1)
fi

echo "Playing $wargame"
echo "Currently at level: $level"
echo "Password for current level: $SSHPASS"
