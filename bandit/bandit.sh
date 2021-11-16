#!/bin/bash

#Quality of like script for OverTheWire games

#Create a log for each level (will overwrite if there already exists a log for a level)
#Create a vault.txt with all passwords

#takes between 0 - 3 arguments
# $1 = gamename (ie. bandit, natas etc.) if non provided, it will try the current folder name
# $2 = level you want to attempt - if non provided will go to the level found last 
# $3 = password to level - if non provided will look for match in vault.txt (this is primarily used for the first level)

#when the password is found, type "is pw" (while still connected via SSH)

vault="$(pwd)/vault.txt"

#
#Setup wargame, level and password
#

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
echo "playing $wargame"
echo "Currently at level: $level"
echo "Password for current level: $SSHPASS"

host='@bandit.labs.overthewire.org'
port='2220'
ssh=$wargame$level$host' -p '$port

export SSHPASS=$SSHPASS

#Establish SSH connection
sshpass -e ssh $ssh | tee "$(pwd)/logs/$wargame$level.txt"

$(mkdir -p "./logs")

#look for "is pw" in log 
if $(grep -q -B 1 'is pw' "$(pwd)/logs/$wargame$level.txt") 
then
#set next level password
	nextpass=$(grep -B 1 'is pw' "$(pwd)/logs/$wargame$level.txt" | head -1 )
	nextlevel=$((level+1))
#write to vault
	toVault="$wargame$nextlevel $nextpass"
	echo $toVault >> vault.txt
fi
