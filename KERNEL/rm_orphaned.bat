#! /bin/sh

while [ true ]
do
	MAX_LINE=`sed -n $= GENERIC_MY_KERNEL`
	COUNT_LINE=1
	COUNT_RM_ORPHANED=0
	while [ $COUNT_LINE -le $MAX_LINE ]
	do
		LINE="`sed -n ${COUNT_LINE}p GENERIC_MY_KERNEL`"
		if [	-n "`echo "${LINE}" | grep '^#'`" -o \
				-n "`echo "${LINE}" | grep '^machine'`" -o \
				-n "`echo "${LINE}" | grep '^include'`" -o \
				-n "`echo "${LINE}" | grep '^maxusers'`" -o \
				-n "`echo "${LINE}" | grep '^option'`" -o \
				-n "`echo "${LINE}" | grep '^makeoptions'`" -o \
				-n "`echo "${LINE}" | grep '^config'`" -o \
				-n "`cat DMESG.TXT | grep -i "^${MODULE}$"`" -o \
				-z "${LINE}" ]
		then
			echo "${LINE}" >> TEMP_RM_ORPHANED.TXT
		else
			DEPEND="`echo "${LINE}" | awk -F '[^[:alpha:]]at ' '{print $2}' | awk -F '[^[:alpha:]]' '{print $1}'`"
			if [	-n "`cat GENERIC_MY_KERNEL | grep -E "^#${DEPEND}[^[:alpha:]]"`" -a \
					-z "`cat GENERIC_MY_KERNEL | grep -E "^${DEPEND}[^[:alpha:]]"`" -a \
					-n "`cat GENERIC_MY_KERNEL | grep -E "[^[:alpha:]]at "`" ]
			then
				echo "#${LINE}" >> TEMP_RM_ORPHANED.TXT
				COUNT_RM_ORPHANED=$((${COUNT_RM_ORPHANED}+1))
			else
				echo "${LINE}" >> TEMP_RM_ORPHANED.TXT
			fi
		fi	

	clear
	echo ${MAX_LINE}:${COUNT_LINE}
	echo "remove ${COUNT_RM_ORPHANED} orphan module! \n"

	COUNT_LINE=$((${COUNT_LINE}+1))
	done

	mv -v TEMP_RM_ORPHANED.TXT GENERIC_MY_KERNEL

	if [ $COUNT_RM_ORPHANED -eq 0 ]
	then
		exit
	fi

done

