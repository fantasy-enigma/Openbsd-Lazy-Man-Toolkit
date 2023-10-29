#! /bin/sh

URL_HEAD="$1"
URL_NECK_BEGIN="$2"
URL_NECK_END="$3"
URL_TAIL="$4"
ERR_COUNT=0

URL_NECK_LENGTH=`echo $URL_NECK_BEGIN | awk '{print length($1)}'`
URL_NECK_END=`expr $URL_NECK_END + 0`

while [ true ]
do
	doas -u caven ftp -o /home/caven/Downloads/${URL_NECK_BEGIN}.temp "${URL_HEAD}${URL_NECK_BEGIN}${URL_TAIL}"
	if [ $? -ne 0 ]
	then
		ERR_COUNT=`expr $ERR_COUNT + 1`
		echo "can't fetch fragement ${URL_NECK_BEGIN} "

		if [ $ERR_COUNT -gt 3 ]
		then
			exit
		fi
	fi


	URL_NECK_BEGIN=`expr $URL_NECK_BEGIN + 1`
	if [ $URL_NECK_BEGIN -gt $URL_NECK_END ]
	then
		echo "finish!"
		exit
	else
		while [ `echo $URL_NECK_BEGIN | awk '{print length($1)}'` -lt $URL_NECK_LENGTH ]
		do
			URL_NECK_BEGIN="0${URL_NECK_BEGIN}"
		done
	fi

done