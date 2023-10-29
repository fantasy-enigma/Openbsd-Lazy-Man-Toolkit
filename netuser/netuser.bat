#! /bin/sh

cat user.txt  | grep -Ev '(apple|dosen)' | xargs -n 1 -J % userdel  %
cat user.txt  | grep -Ev '(apple|dosen)' | xargs -n 1 -J % groupdel %
cat group.txt | grep -Ev '(apple|dosen)' | xargs -n 1 -J % groupdel %

LINES_MAX=`sed -n '$'= user.txt`
LINES_MAX=`expr $LINES_MAX + 0`
LINES_COUNTER=`expr 0 + 1`

while [ $LINES_COUNTER -le $LINES_MAX ]
do
	USER_NAME=`sed -n ${LINES_COUNTER}p user.txt`
	USER_LINE=`cat /etc/passwd | grep ${USER_NAME}:`

	GROUP_NAME=$USER_NAME	
	GROUP_LINE=`cat /etc/group | grep ${GROUP_NAME}:`

	USER_DIR=/home/${USER_NAME}/

	if [ -z "$USER_LINE" ]
	then
		if [ -d $USER_DIR ]
		then
			echo "user path $USER_DIR is exsist!"
			if [ -n "$GROUP_LINE" ]
			then
				echo "group $GROUP_NAME is exist!"
				useradd -og $GROUP_NAME $USER_NAME
			else
				useradd -o $USER_NAME
			fi
		else
			if [ -n "$GROUP_LINE" ]
			then
				echo "group $GROUP_NAME is exist!"
				useradd -mog $GROUP_NAME $USER_NAME
			else
				useradd -mo $USER_NAME
			fi
		fi
	else
		echo "user $USER_NAME is exist!"
	fi
		LINES_COUNTER=`expr $LINES_COUNTER + 1`
done

LINES_MAX=`sed -n '$'= group.txt`
LINES_MAX=`expr $LINES_MAX + 0`
LINES_COUNTER=`expr 0 + 1`

while [ $LINES_COUNTER -le $LINES_MAX ]
do
	GROUP_NAME=`sed -n ${LINES_COUNTER}p group.txt`
	GROUP_LINE=`cat /etc/group | grep ${GROUP_NAME}:`

	if [ -z "$GROUP_LINE" ]
	then
		groupadd -o $GROUP_NAME
	else
		echo "group $GROUP_NAME is exist!"
	fi
		LINES_COUNTER=`expr $LINES_COUNTER + 1`
done

