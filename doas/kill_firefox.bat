#! /bin/sh

while [ "`ps -U firefox -o pid | grep -v '  PID'`" ]
do
	ps -U firefox -o pid | grep -v '  PID' | awk -F ' ' '{print $1}' | xargs -n 1 -J % doas -u firefox kill %
	sleep 1
done
