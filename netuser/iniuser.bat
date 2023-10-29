#! /bin/sh

chflags -R nouchg /home/
rm -rf /home/rootonly/skel/
cp -a /etc/skel/ /home/rootonly/
rm -rf /home/rootonly/skel/.ssh/
chflags uchg /home/rootonly/skel/.*


LINES_MAX=`sed -n '$'= user.txt`
LINES_MAX=`expr $LINES_MAX + 0`
LINES_COUNTER=`expr 0 + 1`

while [ $LINES_COUNTER -le $LINES_MAX ]
do
	USER_NAME=`sed -n ${LINES_COUNTER}p user.txt`

	if [ -d /home/${USER_NAME}/ ]
	then
		chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/
		chmod -R 750 /home/${USER_NAME}/
		chflags uchg /home/${USER_NAME}/.xsession
		chflags uchg /home/${USER_NAME}/.xsession.bak
		cp -a /home/rootonly/skel/.* /home/${USER_NAME}/
		chmod -R 700 /home/${USER_NAME}/.ssh/
		rm -rf /home/${USER_NAME}/.ssh/*
	fi

	LINES_COUNTER=`expr $LINES_COUNTER + 1`
done


if [ -f /etc/login.conf.original ]
then
	echo "\n### found /etc/login.conf.original ###"
else
	cp -av /etc/login.conf /etc/login.conf.original
fi

if [ -f login.conf.original ]
then
	if [ -z "`diff /etc/login.conf.original login.conf.original`" ]
	then
		cp -av login.conf /etc/
		sync
		cap_mkdb /etc/login.conf
		sync
	else
		echo "\n### login.conf.original missmatch, please copy it from /etc/ and make sure a new login.conf edit from it. ###"
	fi
else
	echo "\n### no login.conf.original to match, please copy it from /etc/ and make sure a new login.conf edit from it. ###"
fi

