#! /bin/sh

TIME_TO_SECONDES(){
FILE_MONTH=$1
FILE_DAY=$2
FILE_TIME=$3
FILE_YEAR=$4

TIME_HOUR=`echo $FILE_TIME | awk -F ':' '{print $1}' | sed s/^0//g`
TIME_MINUTE=`echo $FILE_TIME | awk -F ':' '{print $2}' | sed s/^0//g`
TIME_SECONDES=`echo $FILE_TIME | awk -F ':' '{print $3}' | sed s/^0//g`

## month day year number isn't fully, need -1 ##
FULL_MONTH=$(($FILE_MONTH-1))
FULL_DAY=$(($FILE_DAY-1))
FULL_YEAR=$(($FILE_YEAR-1))

FULL_YEAR_DAY=$(($FULL_YEAR/4-$FULL_YEAR/100+$FULL_YEAR/400+$FULL_YEAR*365))

if [ $(($FILE_YEAR%4)) -eq 0 -a $(($FILE_YEAR%100)) -ne 0 -a $(($FILE_YEAR%400)) -eq 0 ]
then
	case $FULL_MONTH in
		0)	FULL_MONTH_DAY=0	;;
		1)	FULL_MONTH_DAY=31	;;
		2)	FULL_MONTH_DAY=60	;;
		3)	FULL_MONTH_DAY=91	;;
		4)	FULL_MONTH_DAY=121	;;
		5)	FULL_MONTH_DAY=152	;;
		6)	FULL_MONTH_DAY=182	;;
		7)	FULL_MONTH_DAY=213	;;
		8)	FULL_MONTH_DAY=244	;;
		9)	FULL_MONTH_DAY=274	;;
		10)	FULL_MONTH_DAY=305	;;
		11)	FULL_MONTH_DAY=335	;;
		12)	FULL_MONTH_DAY=366	;;
	esac
else	
	case $FULL_MONTH in
		0)	FULL_MONTH_DAY=0	;;
		1)	FULL_MONTH_DAY=31	;;
		2)	FULL_MONTH_DAY=59	;;
		3)	FULL_MONTH_DAY=90	;;
		4)	FULL_MONTH_DAY=120	;;
		5)	FULL_MONTH_DAY=151	;;
		6)	FULL_MONTH_DAY=181	;;
		7)	FULL_MONTH_DAY=212	;;
		8)	FULL_MONTH_DAY=243	;;
		9)	FULL_MONTH_DAY=273	;;
		10)	FULL_MONTH_DAY=304	;;
		11)	FULL_MONTH_DAY=334	;;
		12)	FULL_MONTH_DAY=365	;;
	esac
fi

SECONDES_SUMMATION=$(($FULL_YEAR_DAY*86400+$FULL_MONTH_DAY*86400+$FULL_DAY*86400+$TIME_HOUR*3600+$TIME_MINUTE*60+$TIME_SECONDES))
echo $SECONDES_SUMMATION
}

KEY_KEEP=$1


LINE_MAX=`sed -n '$=' ~/DFC_SAME_HASH_LIST.TXT`
A_COUNT=$LINE_MAX

while [ $A_COUNT -ge 2 ]
do
	echo "$B_COUNT : \n"
	A_LINE="`sed -n ${A_COUNT}p ~/DFC_SAME_HASH_LIST.TXT`"
	if [ -n "$A_LINE" ]
	then
		A_MONTH=`echo "$A_LINE" | awk -F ' ' '{print $4}'`
		A_DAY=`echo "$A_LINE" | awk -F ' ' '{print $6}'`
		A_TIME=`echo "$A_LINE" | awk -F ' ' '{print $8}'`
		A_YEAR=`echo "$A_LINE" | awk -F ' ' '{print $10}'`
		A_PATH="./`echo "$A_LINE" | awk -F '[\.]/' '{print $2}'`"
		A_NAME=`echo "$A_PATH" | awk -F '/' '{print $NF}'`
		A_DIR=`echo "$A_PATH" | awk -F "$A_NAME" '{print $1}'`
		A_PATH_LENGTH=`echo $A_PATH | awk '{print length($0)}'`
		A_NAME_LENGTH=`echo $A_NAME | awk '{print length($0)}'`		
		A_DIR_LENGTH=`echo $A_DIR | awk '{print length($0)}'`
		A_SECONDES_SUMMATION=`TIME_TO_SECONDES $A_MONTH $A_DAY $A_TIME $A_YEAR`

		B_COUNT=$(($A_COUNT-1))
		while [ $B_COUNT -ge 1 ]
		do
			B_LINE="`sed -n ${B_COUNT}p ~/DFC_SAME_HASH_LIST.TXT`"
				if [ -n "$B_LINE" ]
				then
					B_MONTH=`echo "$B_LINE" | awk -F ' ' '{print $4}'`
					B_DAY=`echo "$B_LINE" | awk -F ' ' '{print $6}'`
					B_TIME=`echo "$B_LINE" | awk -F ' ' '{print $8}'`
					B_YEAR=`echo "$B_LINE" | awk -F ' ' '{print $10}'`
					B_PATH="./`echo "$B_LINE" | awk -F '[\.]/' '{print $2}'`"
					B_NAME=`echo "$B_PATH" | awk -F '/' '{print $NF}'`
					B_DIR=`echo "$B_PATH" | awk -F "$B_NAME" '{print $1}'`
					B_PATH_LENGTH=`echo $B_PATH | awk '{print length($0)}'`
					B_NAME_LENGTH=`echo $B_NAME | awk '{print length($0)}'`		
					B_DIR_LENGTH=`echo $B_DIR | awk '{print length($0)}'`
					B_SECONDES_SUMMATION=`TIME_TO_SECONDES $B_MONTH $B_DAY $B_TIME $B_YEAR`

				else
					A_COUNT=$B_COUNT
					break
				fi

				if [ "$KEY_KEEP" = "keep_oldest" ]
				then
					echo "$A_SECONDES_SUMMATION\n$B_SECONDES_SUMMATION"
					if [ $A_SECONDES_SUMMATION -lt $B_SECONDES_SUMMATION ]
					then
						mv -fv "$B_PATH" ./DFC_TRASH/
					elif [ $A_SECONDES_SUMMATION -gt $B_SECONDES_SUMMATION ]
					then
						mv -fv "$A_PATH" ./DFC_TRASH/
						A_COUNT=$B_COUNT
						break
					fi
				fi

				if [ "$KEY_KEEP" = "keep_newest" ]
				then
					echo "$A_SECONDES_SUMMATION\n$B_SECONDES_SUMMATION"
					if [ $A_SECONDES_SUMMATION -gt $B_SECONDES_SUMMATION ]
					then
						mv -fv "$B_PATH" ./DFC_TRASH/
					elif [ $A_SECONDES_SUMMATION -lt $B_SECONDES_SUMMATION ]
					then
						mv -fv "$A_PATH" ./DFC_TRASH/
						A_COUNT=$B_COUNT
						break
					fi
				fi

				if [ "$KEY_KEEP" = "keep_name_shortest" ]
				then
					if [ $A_NAME_LENGTH -lt $B_NAME_LENGTH ]
					then
						mv -fv "$B_PATH" ./DFC_TRASH/
					elif [ $A_NAME_LENGTH -gt $B_NAME_LENGTH ]
					then
						mv -fv "$A_PATH" ./DFC_TRASH/
						A_COUNT=$B_COUNT
						break
					fi
				fi

				if [ "$KEY_KEEP" = "keep_name_longest" ]
				then
					if [ $A_NAME_LENGTH -gt $B_NAME_LENGTH ]
					then
						mv -fv "$B_PATH" ./DFC_TRASH/
					elif [ $A_NAME_LENGTH -lt $B_NAME_LENGTH ]
					then
						mv -fv "$A_PATH" ./DFC_TRASH/
						A_COUNT=$B_COUNT
						break
					fi
				fi

				if [ "$KEY_KEEP" = "keep_path_shortest" ]
				then
					if [ $A_PATH_LENGTH -lt $B_PATH_LENGTH ]
					then
						mv -fv "$B_PATH" ./DFC_TRASH/
					elif [ $A_PATH_LENGTH -gt $B_PATH_LENGTH ]
					then
						mv -fv "$A_PATH" ./DFC_TRASH/
						A_COUNT=$B_COUNT
						break
					fi
				fi

				if [ "$KEY_KEEP" = "keep_path_longest" ]
				then
					if [ $A_PATH_LENGTH -gt $B_PATH_LENGTH ]
					then
						mv -fv "$B_PATH" ./DFC_TRASH/
					elif [ $A_PATH_LENGTH -lt $B_PATH_LENGTH ]
					then
						mv -fv "$A_PATH" ./DFC_TRASH/
						A_COUNT=$B_COUNT
						break
					fi
				fi

				if [ "$KEY_KEEP" = "keep_dir_shortest" ]
				then
					if [ $A_DIR_LENGTH -lt $B_DIR_LENGTH ]
					then
						mv -fv "$B_PATH" ./DFC_TRASH/
					elif [ $A_DIR_LENGTH -gt $B_DIR_LENGTH ]
					then
						mv -fv "$A_PATH" ./DFC_TRASH/
						A_COUNT=$B_COUNT
						break
					fi
				fi

				if [ "$KEY_KEEP" = "keep_dir_longest" ]
				then
					if [ $A_DIR_LENGTH -gt $B_DIR_LENGTH ]
					then
						mv -fv "$B_PATH" ./DFC_TRASH/
					elif [ $A_DIR_LENGTH -lt $B_DIR_LENGTH ]
					then
						mv -fv "$A_PATH" ./DFC_TRASH/
						A_COUNT=$B_COUNT
						break
					fi
				fi
		B_COUNT=$(($B_COUNT-1))
		done
	fi
A_COUNT=$(($A_COUNT-1))
done

rm -f ~/DFC_SAME_HASH_REFRESH.TXT
if [ -f ~/DFC_SAME_HASH_REFRESH.TXT ]
then
	echo "can't rm ~/DFC_SAME_HASH_REFRESH.TXT"
	exit
fi

LINE_MAX=`sed -n $= ~/DFC_SAME_HASH_LIST.TXT`
while [ $LINE_MAX -ge 1 ]
do
	LINE="`sed -n ${LINE_MAX}p ~/DFC_SAME_HASH_LIST.TXT`"
	if [ -n "$LINE" ]
	then
		FILE_PATH="./`echo "$LINE" | awk -F '[\.]/' '{print $2}'`"
		if [ -f "$FILE_PATH" ]
		then
			echo "$LINE" >> ~/DFC_SAME_HASH_REFRESH.TXT
		fi
	fi
LINE_MAX=$(($LINE_MAX-1))
done

rm -f ~/DFC_SAME_HASH_LIST.TXT

LINE_MAX=`sed -n $= ~/DFC_SAME_HASH_REFRESH.TXT`
A_COUNTER=$LINE_MAX
B_COUNTER=$(($LINE_MAX-1))
LINE_A="`sed -n ${A_COUNTER}p ~/DFC_SAME_HASH_REFRESH.TXT`"
A_HASH_NUMBER="`echo "$LINE_A" | awk -F ' ' '{print $12}'`"
LINE_B="`sed -n ${B_COUNTER}p ~/DFC_SAME_HASH_REFRESH.TXT`"
B_HASH_NUMBER="`echo "$LINE_B" | awk -F ' ' '{print $12}'`"
while [ true ]
do
	if [ -n "$LINE_A" -a -n "$LINE_B" ]
	then
		if [ "$A_HASH_NUMBER" = "$B_HASH_NUMBER" -a $FLAG_DUMPLICATE -eq 0 ]
		then
			echo "${LINE_A}\n${LINE_B}" >> ~/DFC_SAME_HASH_LIST.TXT
			FLAG_DUMPLICATE=1
		elif [ "$A_HASH_NUMBER" = "$B_HASH_NUMBER" -a $FLAG_DUMPLICATE -ge 1 ]
		then
			echo "${LINE_B}" >> ~/DFC_SAME_HASH_LIST.TXT
		elif [ "$A_HASH_NUMBER" != "$B_HASH_NUMBER" ]
		then
			if [ $FLAG_DUMPLICATE -ge 1 ]
			then
				echo "" >> ~/DFC_SAME_HASH_LIST.TXT
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
	LINE_A="`sed -n ${A_COUNTER}p ~/DFC_SAME_HASH_REFRESH.TXT`"
	A_HASH_NUMBER=`echo "$LINE_A" | awk -F ' ' '{print $12}'`
	
	if [ -n "$LINE_A" -a -n "$LINE_B" ]
	then
		if [ "$A_HASH_NUMBER" = "$B_HASH_NUMBER" -a $FLAG_DUMPLICATE -eq 0 ]
		then
			FLAG_DUMPLICATE=1
			echo "${LINE_B}\n${LINE_A}" >> ~/DFC_SAME_HASH_LIST.TXT
		elif [ "$A_HASH_NUMBER" = "$B_HASH_NUMBER" -a $FLAG_DUMPLICATE -ge 1 ]
		then
			echo "${LINE_A}" >> ~/DFC_SAME_HASH_LIST.TXT
		elif [ "$A_HASH_NUMBER" != "$B_HASH_NUMBER" ]
		then
			if [ $FLAG_DUMPLICATE -ge 1 ]
			then
				echo "" >> ~/DFC_SAME_HASH_LIST.TXT
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
	LINE_B="`sed -n ${B_COUNTER}p ~/DFC_SAME_HASH_REFRESH.TXT`"
	B_HASH_NUMBER=`echo "$LINE_B" | awk -F ' ' '{print $12}'`

done

rm -f ~/DFC_SAME_HASH_REFRESH.TXT




