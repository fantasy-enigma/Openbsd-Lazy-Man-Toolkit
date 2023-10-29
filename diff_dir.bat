#! /bin/sh

HASH_A_DIR="$1"
HASH_B_DIR="$2"


HASH_A="`find "$HASH_A_DIR" -type f -print0 | xargs -0 -n 1 -J % sha256 %`"
HASH_B="`find "$HASH_B_DIR" -type f -print0 | xargs -0 -n 1 -J % sha256 %`"

HASH_A_MAX=`echo $HASH_A | awk -F 'SHA256' '{printf NF}'`

HASH_B_MAX=`echo $HASH_B | awk -F 'SHA256' '{printf NF}'`

HASH_A_COUNTER=$HASH_A_MAX
while [ $HASH_A_COUNTER -ge 1 ]
do
	HASH_A_ARR[$HASH_A_COUNTER]="`echo $HASH_A | awk -F 'SHA256 ' "{printf $"$HASH_A_COUNTER"}"`"
	HASH_A_COUNTER=$(($HASH_A_COUNTER-1))
done

HASH_B_COUNTER=$HASH_B_MAX
while [ $HASH_B_COUNTER -ge 1 ]
do
	HASH_B_ARR[$HASH_B_COUNTER]="`echo $HASH_B | awk -F 'SHA256 ' "{printf $"$HASH_B_COUNTER"}"`"
	HASH_B_COUNTER=$(($HASH_B_COUNTER-1))
done

rm -f ~/DIFF_DIR.TXT
if [ -f ~/DIFF_DIR.TXT ]
then
	echo "can't rm ~/DIFF_DIR.TXT,please rm it and try again!!!"
	exit
fi

echo "${HASH_A_DIR} <=> ${HASH_B_DIR}" 
HASH_A_COUNTER=$HASH_A_MAX
while [ $HASH_A_COUNTER -ge 1 ]
do
	FLAG_MISSMATCH=1
	LINE_HASH_A="${HASH_A_ARR[$HASH_A_COUNTER]}"
	if [ -n "$LINE_HASH_A" ]
	then
		LINE_NAME_HASH_A="`echo "$LINE_HASH_A" | awk -F "[\(]$HASH_A_DIR" '{printf $2}' | sed s/' $'//g`"
		echo "=============================================================================================="
		echo "$LINE_NAME_HASH_A"
		echo "----------------------------------------------------------------------------------------------"
		HASH_B_COUNTER=$HASH_B_MAX
		while [ $HASH_B_COUNTER -ge 1 ]
		do
			LINE_HASH_B="${HASH_B_ARR[$HASH_B_COUNTER]}"
			if [ -n "$LINE_HASH_B" ]
			then
				LINE_NAME_HASH_B="`echo "$LINE_HASH_B" | awk -F "[\(]$HASH_B_DIR" '{printf $2}' | sed s/' $'//g`"
				echo "$LINE_NAME_HASH_B"
				if [ "$LINE_NAME_HASH_A" = "$LINE_NAME_HASH_B" ]
				then		
					echo "file match!!!\n==============================================================================================\n\n"
					FLAG_MISSMATCH=0
					break
				else
					echo "----------------------------------------------------------------------------------------------"
				fi
			fi
			HASH_B_COUNTER=$(($HASH_B_COUNTER-1))
		done

		if [ $FLAG_MISSMATCH -eq 1 ]
		then
			echo "\n\n"
			echo "$LINE_HASH_A" >> ~/DIFF_DIR.TXT
		fi

	fi

	HASH_A_COUNTER=$(($HASH_A_COUNTER-1))
done

echo "${HASH_B_DIR} <=> ${HASH_A_DIR}" 
HASH_B_COUNTER=$HASH_B_MAX
while [ $HASH_B_COUNTER -ge 1 ]
do
	FLAG_MISSMATCH=1
	LINE_HASH_B="${HASH_B_ARR[$HASH_B_COUNTER]}"
	if [ -n "$LINE_HASH_B" ]
	then
		LINE_NAME_HASH_B="`echo "$LINE_HASH_B" | awk -F "[\(]$HASH_B_DIR" '{printf $2}' | sed s/' $'//g`"
		echo "=============================================================================================="
		echo "$LINE_NAME_HASH_B"
		echo "----------------------------------------------------------------------------------------------"

		HASH_A_COUNTER=$HASH_A_MAX
		while [ $HASH_A_COUNTER -ge 1 ]
		do
			LINE_HASH_A="${HASH_A_ARR[$HASH_A_COUNTER]}"
			if [ -n "$LINE_HASH_A" ]
			then
				LINE_NAME_HASH_A="`echo "$LINE_HASH_A" | awk -F "[\(]$HASH_A_DIR" '{printf $2}' | sed s/' $'//g`"
				echo "$LINE_NAME_HASH_A"
				if [ "$LINE_NAME_HASH_A" = "$LINE_NAME_HASH_B" ]
				then
					echo "file match!!!\n==============================================================================================\n\n"
					FLAG_MISSMATCH=0
					break
				else
					echo "----------------------------------------------------------------------------------------------"
				fi
			fi
			HASH_A_COUNTER=$(($HASH_A_COUNTER-1))
		done

		if [ $FLAG_MISSMATCH -eq 1 ]
		then
			echo "\n\n"
			echo "$LINE_HASH_B" >> ~/DIFF_DIR.TXT
		fi

	fi

	HASH_B_COUNTER=$(($HASH_B_COUNTER-1))
done















