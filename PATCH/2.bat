#! /bin/sh

PATCH_LOG_LINE_MAX=`sed -n $= PATCH.LOG`
PATCH_LOG_LINE_COUNTER=1

while [ $PATCH_LOG_LINE_COUNTER -le $PATCH_LOG_LINE_MAX ]
do
	PATCH_LOG_LINE="`sed -n ${PATCH_LOG_LINE_COUNTER}p PATCH.LOG | grep -E '(^[\|] +)|^[\|]$' | sed s/'^[\|]'//g`"
	if [ -n "$PATCH_LOG_LINE" ]
	then
		if [ "`echo "$PATCH_LOG_LINE" | grep -E 'signify -Vep '`" ]
		then
			echo "\n" >> BUILD.BAT
			while [ "`echo "$PATCH_LOG_LINE" | grep -E '\ *$'`" ]
			do
				PATCH_LOG_LINE_COUNTER=$(($PATCH_LOG_LINE_COUNTER+1))
				PATCH_LOG_LINE="`sed -n ${PATCH_LOG_LINE_COUNTER}p PATCH.LOG | grep -E '(^[\|] +)|^[\|]$' | sed s/'^[\|]'//g`"
			done
		else
			echo "$PATCH_LOG_LINE" >> BUILD.BAT
		fi
	fi
PATCH_LOG_LINE_COUNTER=$(($PATCH_LOG_LINE_COUNTER+1))
done

sh ./BUILD.BAT 1>>./BUILD.LOG 2>>./BUILD.ERR
date >> /PATCH_INSTALLED.TXT
cat PATCH_FILE_LIST.TXT >> /PATCH_INSTALLED.TXT
