#! /bin/sh

LINES_MAX=`sed -n $= ~/Makefile_DIR.txt`
LINES_MAX=`expr $LINES_MAX + 0`

LINES_COUNTER=`expr 0 + 1`
while [ $LINES_COUNTER -le $LINES_MAX ]
do
	First_Line=`sed -n 1p ~/Makefile_DIR.txt`
	LINES_COUNTER2=`expr 0 + 1`
	while [ $LINES_COUNTER2 -le $LINES_MAX ]
	do
		Makefile_DIR=`sed -n ${LINES_COUNTER2}p ~/Makefile_DIR.txt`
		if [ -n "`echo "$Makefile_DIR" | grep "$First_Line"`" ]
		then
			echo "clean Duplicate directory or subdirectory: $Makefile_DIR"
		else
			echo "$Makefile_DIR" >> ~/Makefile_DIR_rmdup.txt
		fi
		LINES_COUNTER2=`expr $LINES_COUNTER2 + 1`
	done
	echo "$First_Line" >> ~/Makefile_DIR_rmdup.txt
	mv ~/Makefile_DIR_rmdup.txt ~/Makefile_DIR.txt
	LINES_COUNTER=`expr $LINES_COUNTER + 1`
	LINES_MAX=`sed -n $= ~/Makefile_DIR.txt`
done

cat ~/Makefile_DIR.txt | grep /usr/src/gnu/ >> ~/Makefile_DIR_gnu_first.txt
cat ~/Makefile_DIR.txt | grep -v /usr/src/gnu/ >> ~/Makefile_DIR_gnu_first.txt
mv ~/Makefile_DIR_gnu_first.txt ~/Makefile_DIR.txt
