#! /bin/sh

LIB_DIR=$1
if [ -z "$LIB_DIR" ]
then
	LIB_DIR="./"
fi

rm -f ~/LIB_DATA_BASE/lib_list.txt

find $LIB_DIR -type d | sed s/'^\.\/'//g | sed s/'^\/'//g | xargs -n 1 -I {_DIR_NAME_} mkdir -p ~/LIB_DATA_BASE/{_DIR_NAME_}
find $LIB_DIR -type f >> ~/LIB_DATA_BASE/lib_list.txt


LINE_MAX=`sed -n '$=' ~/LIB_DATA_BASE/lib_list.txt`

while [ $LINE_MAX -ge 1 ]
do
	clear
	echo "creating lib_data_base \n $LINE_MAX"
	LINE="`sed -n ${LINE_MAX}p ~/LIB_DATA_BASE/lib_list.txt`"
	if [ -n "$LINE" ]
	then
		echo "" >> ~/LIB_DATA_BASE/${LINE}
		nm ${LINE} >> ~/LIB_DATA_BASE/`echo "${LINE}" | sed s/'^\.\/'//g | sed s/'^\/'//g` 2>> /dev/null
	fi
	
LINE_MAX=$(($LINE_MAX - 1))
done