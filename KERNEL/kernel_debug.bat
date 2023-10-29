#! /bin/sh

METHOLD=$1

rm -f ERROR_LINE.TXT
if [ -f ERROR_LINE.TXT ]
then
	echo "Can't create ERROR_LINE.TXT \n"
	exit
fi

rm -f MODULE_LOST.TXT
if [ -f MODULE_LOST.TXT ]
then
	echo "Can't create MODULE_LOST.TXT \n"
	exit
fi


if [ "$METHOLD" = "add" ]
then
	echo "Will add depended modules to config file. \n"
	cat err.txt | grep -E ' is orphaned$' | sed s/'^.*at '//g | sed s/'[^[:alpha:]].*$'//g >> MODULE_LOST.TXT
	cat MODULE_LOST.TXT | xargs -n1 -I {_MODULE_} sed -i 's/^#{_MODULE_}/{_MODULE_}/g' GENERIC_MY_KERNEL
else
	echo "Will remove orphan modules from config file. \n"
	cat err.txt | grep -E ' is orphaned$' | awk -F ':' '{print $2}' >> ERROR_LINE.TXT
	cat ERROR_LINE.TXT | xargs -n1 -I {_LINE_NUMBER_} sed -i '{_LINE_NUMBER_}s/^/#/g' GENERIC_MY_KERNEL
	sed -i 's/^#{2,}/#/g' GENERIC_MY_KERNEL
fi