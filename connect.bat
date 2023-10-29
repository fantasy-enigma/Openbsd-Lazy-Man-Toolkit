#! /bin/sh

KEY="$1"
while [ true ] 
do
	clear
	fstat | grep internet | grep "$KEY"
	sleep 1
done
