#! /bin/sh

LINES_MAX=`sed -n $= ~/update_dir_rmdup.txt`
LINES_MAX=`expr $LINES_MAX + 0`
LINES_COUNTER=`expr 0 + 1`
WK_DIR=`pwd`

rm -fv ~/Makefile_DIR.txt 

while [ $LINES_COUNTER -le $LINES_MAX ]
do
	Makefile_DIR=/usr/`sed -n ${LINES_COUNTER}p ~/update_dir_rmdup.txt`
	echo "check $LINES_COUNTER/$LINES_MAX :"

	FLAG_BOUNDARY=`expr 0 + 1`
	while [ $FLAG_BOUNDARY -eq 1 ]
	do
		BOUNDARY_MAX=`sed -n $= ${WK_DIR}/boundary.txt`
		BOUNDARY_MAX=`expr $BOUNDARY_MAX + 0`
		BOUNDARY_COUNTER=`expr 0 + 1`
		FLAG_BOUNDARY=`expr 0 + 0`
		while [ $BOUNDARY_MAX -ge $BOUNDARY_COUNTER ]
		do
			BOUNDARY=`sed -n ${BOUNDARY_COUNTER}p ${WK_DIR}/boundary.txt`
			if [ -n "`echo "$Makefile_DIR" | grep "^$BOUNDARY"`" ]
			then
				FLAG_BOUNDARY=`expr 0 + 1`
				echo $Makefile_DIR
				echo "ok, in boundary:$BOUNDARY"
			fi
			BOUNDARY_COUNTER=`expr $BOUNDARY_COUNTER + 1`
		done

		FLAG_MAKEFILE=`expr 0 + 0`
		if [ -f "${Makefile_DIR}Makefile" -o -f "${Makefile_DIR}Makefile.bsd-wrapper" ]
		then
			FLAG_MAKEFILE=`expr 0 + 1`
		fi

		if [ $FLAG_BOUNDARY -eq 1 ]
		then
			if [ $FLAG_MAKEFILE -eq 1 ]
			then
				FLAG_BOUNDARY=`expr 0 + 0`
				echo "Makefile is exsit"
				echo "export path..."
				echo "$Makefile_DIR" >> ~/Makefile_DIR.txt 
			else
				echo "no Makefile"
				echo "cd ../ and try again."
				cd $Makefile_DIR
				cd ..
				Makefile_DIR="`pwd`/"
			fi
		else
			echo $Makefile_DIR
			echo "cross boundary, netx one"	
		fi

	done

	LINES_COUNTER=`expr $LINES_COUNTER + 1`
done
