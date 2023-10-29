#! /bin/sh

DIGIT_TO_IP(){
DIGIT=$1
IP_PART_A=$(($DIGIT/16777216))
IP_PART_B=$(($DIGIT%16777216/65536))
IP_PART_C=$(($DIGIT%65536/256))
IP_PART_D=$(($DIGIT%256))
echo "${IP_PART_A}.${IP_PART_B}.${IP_PART_C}.${IP_PART_D}"
}

COUNTRY_KEY_WORD="$1"

rm -f ./COUNTRY_FILT_${COUNTRY_KEY_WORD}.TXT
if [ -f ./COUNTRY_FILT_${COUNTRY_KEY_WORD}.TXT ]
then
	echo "can't rm ./COUNTRY_FILT_${COUNTRY_KEY_WORD}.TXT"
	exit
fi

rm -f ./IP_FILT_${COUNTRY_KEY_WORD}.TXT
if [ -f ./IP_FILT_${COUNTRY_KEY_WORD}.TXT ]
then
	echo "can't rm ./IP_FILT_${COUNTRY_KEY_WORD}.TXT"
	exit
fi

cat ./ip-to-country.csv | grep "$COUNTRY_KEY_WORD" >> ./COUNTRY_FILT_${COUNTRY_KEY_WORD}.TXT
LINE_MAX=`sed -n $= ./COUNTRY_FILT_${COUNTRY_KEY_WORD}.TXT`
while [ $LINE_MAX -ge 1 ]
do
	clear
	echo $LINE_MAX
	IP_RANG_LINE="`sed -n ${LINE_MAX}p ./COUNTRY_FILT_${COUNTRY_KEY_WORD}.TXT`"
	if [ -n "$IP_RANG_LINE" ]
	then
		COUNTRY_NAME="`echo "$IP_RANG_LINE" | awk -F , '{print $5}'`"
		DIGIT_BEGIN=`echo "$IP_RANG_LINE" | awk -F , '{print $1}'`
		DIGIT_END=`echo "$IP_RANG_LINE" | awk -F , '{print $2}'`
		IP_BEGIN=`DIGIT_TO_IP $DIGIT_BEGIN`
		IP_END=`DIGIT_TO_IP $DIGIT_END`
		
		echo "${IP_BEGIN} - ${IP_END} , 000 , ${COUNTRY_NAME}" >> "IP_FILT_${COUNTRY_KEY_WORD}.TXT"
	fi
	LINE_MAX=$(($LINE_MAX-1))
done

echo "mission comple !"
