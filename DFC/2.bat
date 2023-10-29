#! /bin/sh

FLAG_QUICK_HASH="$1"

rm -f ~/DFC_SAME_HASH_LIST.TXT
if [ -f ~/DFC_SAME_HASH_LIST.TXT ]
then
	echo "can't rm ~/DFC_SAME_HASH_LIST.TXT"
	exit
fi

LINE_MAX=`sed -n '$=' ~/DFC_SAME_SIZE_LIST.TXT`
while [ $LINE_MAX -ge 1 ]
do
	clear
	echo "hashing files: $LINE_MAX"
	LINE_SAME_SIZE="`sed -n ${LINE_MAX}p ~/DFC_SAME_SIZE_LIST.TXT`"
	if [ -n "$LINE_SAME_SIZE" ]
	then

		FILE_SIZE=`echo $LINE_SAME_SIZE | awk -F ' ' '{print $5}'`
		FILE_MONTH=`echo $LINE_SAME_SIZE | awk -F ' ' '{print $6}'`
		case $FILE_MONTH in
			Jan)	FILE_MONTH=1 ;;
			Feb)	FILE_MONTH=2 ;;
			Mar)	FILE_MONTH=3 ;;
			Apr)	FILE_MONTH=4 ;;
			May)	FILE_MONTH=5 ;;
			Jun)	FILE_MONTH=6 ;;
			Jul)	FILE_MONTH=7 ;;
			Aug)	FILE_MONTH=8 ;;
			Sep)	FILE_MONTH=9 ;;
			Oct)	FILE_MONTH=10 ;;
			Nov)	FILE_MONTH=11 ;;
			Dec)	FILE_MONTH=12 ;;
		esac

		FILE_DAY=`echo $LINE_SAME_SIZE | awk -F ' ' '{print $7}'`
		FILE_TIME=`echo $LINE_SAME_SIZE | awk -F ' ' '{print $8}'`
		FILE_YEAR=`echo $LINE_SAME_SIZE | awk -F ' ' '{print $9}'`
		FILE_PATH="`echo $LINE_SAME_SIZE | awk -F ' ./' '{print "./"$2}'`"

		if [ "$FLAG_QUICK_HASH" = "quick" ]
		then
			HASH_NUMBER="`od -v -b -N 1048576 "$FILE_PATH" | md5`" 2>/dev/null
		else
			HASH_STRING="`md5 "$FILE_PATH"`" 2>/dev/null
			HASH_NUMBER="`echo $HASH_STRING | awk -F '\) = ' '{print $2}'`"
		fi


		if [ -n "$HASH_NUMBER" ]
		then
			echo "S: $FILE_SIZE M: ${FILE_MONTH} D: ${FILE_DAY} T: $FILE_TIME Y: ${FILE_YEAR} HASH: $HASH_NUMBER $FILE_PATH" >> ~/DFC_SAME_HASH_LIST.TXT
		fi
	fi
	LINE_MAX=$(($LINE_MAX-1))
done

rm -f ~/DFC_SAME_HASH_TMP.TXT
if [ -f ~/DFC_SAME_HASH_TMP.TXT ]
then
	echo "can't rm ~/DFC_SAME_HASH_TMP.TXT"
	exit
fi

echo "sort files..."
sort -t ' ' -k 12 ~/DFC_SAME_HASH_LIST.TXT >> ~/DFC_SAME_HASH_TMP.TXT
mv -f ~/DFC_SAME_HASH_TMP.TXT ~/DFC_SAME_HASH_LIST.TXT

LINE_MAX=`sed -n $= ~/DFC_SAME_HASH_LIST.TXT`
A_COUNTER=$LINE_MAX
B_COUNTER=$(($LINE_MAX-1))
LINE_A="`sed -n ${A_COUNTER}p ~/DFC_SAME_HASH_LIST.TXT`"
A_HASH_NUMBER="`echo "$LINE_A" | awk -F ' ' '{print $12}'`"
LINE_B="`sed -n ${B_COUNTER}p ~/DFC_SAME_HASH_LIST.TXT`"
B_HASH_NUMBER="`echo "$LINE_B" | awk -F ' ' '{print $12}'`"
while [ true ]
do

	if [ -n "$LINE_A" -a -n "$LINE_B" ]
	then
		if [ "$A_HASH_NUMBER" = "$B_HASH_NUMBER" -a $FLAG_DUMPLICATE -eq 0 ]
		then
			echo "${LINE_A}\n${LINE_B}" >> ~/DFC_SAME_HASH_TMP.TXT
			FLAG_DUMPLICATE=1
		elif [ "$A_HASH_NUMBER" = "$B_HASH_NUMBER" -a $FLAG_DUMPLICATE -ge 1 ]
		then
			echo "${LINE_B}" >> ~/DFC_SAME_HASH_TMP.TXT
		elif [ "$A_HASH_NUMBER" != "$B_HASH_NUMBER" ]
		then
			if [ $FLAG_DUMPLICATE -ge 1 ]
			then
				echo "" >> ~/DFC_SAME_HASH_TMP.TXT
			fi
			FLAG_DUMPLICATE=0
		fi
	fi

	clear
	echo "$A_COUNTER"
	A_COUNTER=$(($A_COUNTER-2))
	if [ $A_COUNTER -lt 1 ]
	then
		break
	fi

	clear
	echo "sort files: $A_COUNTER"
	LINE_A="`sed -n ${A_COUNTER}p ~/DFC_SAME_HASH_LIST.TXT`"
	A_HASH_NUMBER=`echo "$LINE_A" | awk -F ' ' '{print $12}'`
	
	if [ -n "$LINE_A" -a -n "$LINE_B" ]
	then
		if [ "$A_HASH_NUMBER" = "$B_HASH_NUMBER" -a $FLAG_DUMPLICATE -eq 0 ]
		then
			FLAG_DUMPLICATE=1
			echo "${LINE_B}\n${LINE_A}" >> ~/DFC_SAME_HASH_TMP.TXT
		elif [ "$A_HASH_NUMBER" = "$B_HASH_NUMBER" -a $FLAG_DUMPLICATE -ge 1 ]
		then
			echo "${LINE_A}" >> ~/DFC_SAME_HASH_TMP.TXT
		elif [ "$A_HASH_NUMBER" != "$B_HASH_NUMBER" ]
		then
			if [ $FLAG_DUMPLICATE -ge 1 ]
			then
				echo "" >> ~/DFC_SAME_HASH_TMP.TXT
			fi
			FLAG_DUMPLICATE=0
		fi
	fi

	clear
	echo "$B_COUNTER"
	B_COUNTER=$(($B_COUNTER-2))
	if [ $B_COUNTER -lt 1 ]
	then
		break
	fi

	clear
	echo "sort files: $B_COUNTER"
	LINE_B="`sed -n ${B_COUNTER}p ~/DFC_SAME_HASH_LIST.TXT`"
	B_HASH_NUMBER=`echo "$LINE_B" | awk -F ' ' '{print $12}'`

done

mv -f ~/DFC_SAME_HASH_TMP.TXT ~/DFC_SAME_HASH_LIST.TXT











