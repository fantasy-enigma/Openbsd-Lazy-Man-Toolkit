#! /bin/sh

KERNEL_CONF=GENERIC
DMESG_FORM=dmesg.boot
FILE_OUTPUT=GENERIC_MY_KERNEL

rm -f DMESG.TXT
if [ -f DMESG.TXT ]
	then
		echo "Can't create new DMESG.TXT \n"
		exit
	else
		cat $DMESG_FORM | awk -F '[^[:alpha:]]' '{print $1}' | xargs -n1 -J % echo % >> DMESG.TXT
	fi

rm -f $FILE_OUTPUT
if [ -f $FILE_OUTPUT ]
	then
		echo "Can't create new GENERIC \n"
		exit
	fi

slimming(){ if [	-n "`echo "${LINE}" | grep '^#'`" -o \
						-n "`echo "${LINE}" | grep '^machine'`" -o \
						-n "`echo "${LINE}" | grep '^include'`" -o \
						-n "`echo "${LINE}" | grep '^maxusers'`" -o \
						-n "`echo "${LINE}" | grep '^option'`" -o \
						-n "`echo "${LINE}" | grep '^makeoptions'`" -o \
						-n "`echo "${LINE}" | grep '^config'`" -o \
						-n "`cat DMESG.TXT | grep -i "^${MODULE}$"`" -o \
						-z "${LINE}" ]
				then
					echo "${LINE}" >> $FILE_OUTPUT
				else
					echo "#${LINE}" >> $FILE_OUTPUT
				fi }

LINE_MAX=`sed -n $= ${KERNEL_CONF}`
LINE_COUNT=1

while [ $LINE_COUNT -le $LINE_MAX ]
do
	LINE="`sed -n ${LINE_COUNT}p ${KERNEL_CONF}`"
	MODULE="`echo "${LINE}" | awk -F '[^[:alpha:]]' '{print $1}'`"
	if [ -n "$MODULE" ]
	then
		echo "$MODULE"
	fi

	if [ $# -eq 0 ]
	then
		slimming
	elif [ $# -eq 1 ]
	then
		if [ -n "`echo "${LINE}" | grep -E "at $1[^[:alpha:]]"`" ]
		then
			slimming
		else
			echo "${LINE}" >> $FILE_OUTPUT
		fi
	elif [ $# -eq 2 ]
	then
			if [ $LINE_COUNT -ge $1 -a $LINE_COUNT -le $2 ]
			then
				slimming
			else
				echo "${LINE}" >> $FILE_OUTPUT
			fi
	else
		echo "Wrong parameters exit! \n"
		exit
	fi

LINE_COUNT=$((${LINE_COUNT}+1))
done
