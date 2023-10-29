#! /bin/sh

N_CPU=`sysctl | grep hw.ncpuonline= | awk -F '=' '{print $2}'`
MAX_PROCESSES=$(($N_CPU*2))
WK_DIR=`pwd`
LINES_MAX=`sed -n $= ${WK_DIR}/auto-list.txt`
LINES_MAX=`expr $LINES_MAX + 0`

LINES_COUNTER=`expr 0 + 1`
while [ $LINES_COUNTER -le $LINES_MAX ]
do
	Need_Build=`sed -n ${LINES_COUNTER}p ${WK_DIR}/auto-list.txt | grep -v ^#`

	if [ -n "$Need_Build" -a -d "$Need_Build" ]
	then
		if [ -n "`echo "$Need_Build" | grep "^/usr/src/sys/"`" ]
		then
			if [ -f /usr/src/sys/arch/amd64/conf/GENERIC.MP.CONFIG ]
			then
				cd /usr/src/sys/arch/amd64/conf/
				doas config GENERIC.MP.CONFIG
				cd /usr/src/sys/arch/amd64/compile/GENERIC.MP.CONFIG/
				doas make clean
				doas make cleandir
				doas make obj
				doas make -j $MAX_PROCESSES
				doas make -j $MAX_PROCESSES
				doas make install
			else
				cd /usr/src/sys/arch/amd64/compile/GENERIC.MP/
				doas make clean
				doas make cleandir
				doas make obj
				doas make -j $MAX_PROCESSES
				doas make -j $MAX_PROCESSES
				doas make install
			fi
		elif [ "$Need_Build" = "/usr/xenocara/" ]
		then
			cd "$Need_Build"
			doas make clean
			doas make cleandir
			doas make bootstrap
			doas make obj
			doas make -j $MAX_PROCESSES build
		else
			cd "$Need_Build"
			if [ -f ./Makefile ]
			then
				doas make clean
				doas make cleandir
				doas make obj
				doas make -j $MAX_PROCESSES
				doas make install
			elif [ -f ./Makefile.bsd-wrapper ]
			then
				doas make -f Makefile.bsd-wrapper clean
				doas make -f Makefile.bsd-wrapper cleandir
				doas make -f Makefile.bsd-wrapper obj
				doas make -j $MAX_PROCESSES -f Makefile.bsd-wrapper
				doas make -f Makefile.bsd-wrapper install
			fi
		fi		
	fi

	LINES_COUNTER=`expr $LINES_COUNTER + 1`
done
