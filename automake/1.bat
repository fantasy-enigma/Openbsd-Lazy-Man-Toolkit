#! /bin/sh

rm -fv ~/update_file.txt
if [ -f ~/update_file.txt ]
then
	echo "can't rm ~/update_file.txt"
	exit
else
cat ~/autoCVS.log | grep "^U " | grep -v /.gitignore$ | awk -F '^U ' '{print $2}' > ~/update_file.txt
fi

LINES_MAX=`sed -n $= ~/update_file.txt`
LINES_MAX=`expr $LINES_MAX + 0`
LINES_COUNTER=`expr 0 + 1`

rm -fv ~/update_dir.txt
if [ -f ~/update_dir.txt ]
then
	echo "can't rm ~/update_dir.txt"
	exit
fi

while [ $LINES_COUNTER -le $LINES_MAX ]
do
	FILENAME=`sed -n ${LINES_COUNTER}p ~/update_file.txt | awk -F / '{print $NF}'`
	sed -n ${LINES_COUNTER}p ~/update_file.txt | awk -F $FILENAME '{print $1}' >> ~/update_dir.txt
	LINES_COUNTER=`expr $LINES_COUNTER + 1`
done

LINES_MAX=`sed -n $= ~/update_dir.txt`
LINES_MAX=`expr $LINES_MAX + 0`
LINES_COUNTER=`expr 0 + 1`

rm -fv ~/update_dir_rmdup.txt
if [ -f ~/update_dir_rmdup.txt ]
then
	echo "can't rm ~/update_dir_rmdup.txt"
	exit
fi

while [ $LINES_COUNTER -le $LINES_MAX ]
do
	UPDATE_DIR=`sed -n ${LINES_COUNTER}p ~/update_dir.txt`

	if [ "`cat ~/update_dir_rmdup.txt | grep "$UPDATE_DIR"`" ]
		then	
			echo "clean Duplicate directory: $UPDATE_DIR "
		else
			echo $UPDATE_DIR >> ~/update_dir_rmdup.txt
	fi

	LINES_COUNTER=`expr $LINES_COUNTER + 1`
done
