#! /bin/sh

rm -f ~/DFC_FILES_LIST.TXT
if [ -f ~/DFC_FILES_LIST.TXT ]
then
	echo "can't rm ~/DFC_FILES_LIST.TXT, please rm it and try again."
	exit
fi

rm -f ~/DFC_SAME_SIZE_LIST.TXT
if [ -f ~/DFC_SAME_SIZE_LIST.TXT ]
then
	echo "can't rm ~/DFC_SAME_SIZE_LIST.TXT, please rm it and try again."
	exit
fi

clear
echo "create file list, please wait."
find ./ -type f -print0 2>/dev/null | xargs -0 -n 1 -J % ls -lT % >> ~/DFC_FILES_LIST.TXT
#### ls -lS can't sort comple ####
sort -n -k 5 -t ' ' ~/DFC_FILES_LIST.TXT >> ~/DFC_SAME_SIZE_LIST.TXT
mv ~/DFC_SAME_SIZE_LIST.TXT ~/DFC_FILES_LIST.TXT
LINE_MAX=`sed -n $= ~/DFC_FILES_LIST.TXT`


A_COUNTER=$LINE_MAX
B_COUNTER=$(($LINE_MAX-1))
LINE_A="`sed -n ${A_COUNTER}p ~/DFC_FILES_LIST.TXT`"
A_SIZE=`echo "$LINE_A" | awk -F ' ' '{print $5}'`
LINE_B="`sed -n ${B_COUNTER}p ~/DFC_FILES_LIST.TXT`"
B_SIZE=`echo "$LINE_B" | awk -F ' ' '{print $5}'`
while [ true ]
do

	if [ -n "$LINE_A" -a -n "$LINE_B" ]
	then
		if [ $A_SIZE -eq $B_SIZE -a $FLAG_DUMPLICATE -eq 0 ]
		then
			echo "${LINE_A}\n${LINE_B}" >> ~/DFC_SAME_SIZE_LIST.TXT
			FLAG_DUMPLICATE=1
		elif [ $A_SIZE -eq $B_SIZE -a $FLAG_DUMPLICATE -ge 1 ]
		then
			echo "${LINE_B}" >> ~/DFC_SAME_SIZE_LIST.TXT
		elif [ $A_SIZE -ne $B_SIZE ]
		then
			if [ $FLAG_DUMPLICATE -ge 1 ]
			then
				echo "" >> ~/DFC_SAME_SIZE_LIST.TXT
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
	LINE_A="`sed -n ${A_COUNTER}p ~/DFC_FILES_LIST.TXT`"
	A_SIZE=`echo "$LINE_A" | awk -F ' ' '{print $5}'`
	
	if [ -n "$LINE_A" -a -n "$LINE_B" ]
	then
		if [ $A_SIZE -eq $B_SIZE -a $FLAG_DUMPLICATE -eq 0 ]
		then
			FLAG_DUMPLICATE=1
			echo "${LINE_B}\n${LINE_A}" >> ~/DFC_SAME_SIZE_LIST.TXT
		elif [ $A_SIZE -eq $B_SIZE -a $FLAG_DUMPLICATE -ge 1 ]
		then
			echo "${LINE_A}" >> ~/DFC_SAME_SIZE_LIST.TXT
		elif [ $A_SIZE -ne $B_SIZE ]
		then
			if [ $FLAG_DUMPLICATE -ge 1 ]
			then
				echo "" >> ~/DFC_SAME_SIZE_LIST.TXT
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
	LINE_B="`sed -n ${B_COUNTER}p ~/DFC_FILES_LIST.TXT`"
	B_SIZE=`echo "$LINE_B" | awk -F ' ' '{print $5}'`

done
