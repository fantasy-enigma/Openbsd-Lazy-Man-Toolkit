#! /bin/sh

WORK_DIR="$PWD"

###================ apple ================###

if [ -n "`grep -Re '^apple:' /etc/passwd`" -a -d /home/apple/ ]
	then
		GROUPS_APPLE=
		chown -R apple:apple /home/apple/
		chmod -R 700 /home/apple/
		chmod    750 /home/apple/
	else
		echo "\n no user: "apple" \n please add it in /home/BAT/netuser/user.txt"
		exit
	fi

if [ -n "`grep -Re '^_Xserver_cookies:' /etc/group`" ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},_Xserver_cookies
		CH_PATH="/home/apple/.Xauthority"
		chown -R apple:_Xserver_cookies $CH_PATH
		chmod -R 640 $CH_PATH
	fi

if [ -n "`grep -Re '^_sndio_cookies:' /etc/group`" ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},_sndio_cookies
		CH_PATH="/home/apple/.sndio/"
		chown -R apple:_sndio_cookies $CH_PATH
		chmod -R 770 $CH_PATH
	fi

if [ -n "`grep -Re '^_wireshark:' /etc/group`" ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},_wireshark
	fi

if [ -n "`grep -Re '^_netbrowser:' /etc/group`" ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},_netbrowser
	fi

###================ amule ================###

if [ -n "`grep -Re '^amule:' /etc/passwd`" -a -d /home/amule/ ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},amule
		CH_PATH="/home/amule/.aMule/"
		chmod -R 770 $CH_PATH

		cd /home/amule/
		rm -f .Xauthority
		ln -s /home/apple/.Xauthority .Xauthority

		usermod -S '' amule
		if [ -n "`grep -Re '^_Xserver_cookies:' /etc/group`" ]
			then
				usermod -G apple,_Xserver_cookies,_p2p_share,amuled amule
			fi
	fi

if [ -n "`grep -Re '^amuled:' /etc/passwd`" -a -d /home/amuled/ ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},amuled
		CH_PATH="/home/amuled/.aMule/"
		chmod -R 770 $CH_PATH

		usermod -S '' amuled
		if [ -n "`grep -Re '^_p2p_share:' /etc/group`" ]
			then
				usermod -G _p2p_share amuled
			fi
	fi

###================ mldonkey ================###

if [ -n "`grep -Re '^mldonkey:' /etc/passwd`" -a -d /home/mldonkey/ ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},mldonkey
		CH_PATH="/home/mldonkey/.mldonkey/"
		chmod -R 770 $CH_PATH

		usermod -S '' mldonkey
		if [ -n "`grep -Re '^_p2p_share:' /etc/group`" ]
			then
				usermod -G _p2p_share mldonkey
			fi
	fi

if [ -n "`grep -Re '^mldonkey_gui:' /etc/passwd`" -a -d /home/mldonkey_gui/ ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},mldonkey_gui
		CH_PATH="/home/mldonkey_gui/.mldonkey/"
		chmod -R 770 $CH_PATH

		cd /home/mldonkey_gui/
		rm -f .Xauthority
		ln -s /home/apple/.Xauthority .Xauthority

		usermod -S '' mldonkey_gui
		if [ -n "`grep -Re '^_Xserver_cookies:' /etc/group`" ]
			then
				usermod -G apple,_Xserver_cookies mldonkey_gui
			fi
	fi

###================ chrome ================###

if [ -n "`grep -Re '^chrome:' /etc/passwd`" -a -d /home/chrome/ ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},chrome
		CH_PATH="/home/chrome/Downloads/"
		chmod -R 770 $CH_PATH

		cd /home/chrome/
		rm -f .Xauthority
		ln -s /home/apple/.Xauthority .Xauthority

		usermod -S '' chrome
		if [ -n "`grep -Re '^_Xserver_cookies:' /etc/group`" ]
			then
				usermod -G apple,_Xserver_cookies chrome
			fi
	fi

###================ firefox ================###

if [ -n "`grep -Re '^firefox:' /etc/passwd`" -a -d /home/firefox/ ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},firefox
		CH_PATH="/home/firefox/Downloads/"
		chmod -R 770 $CH_PATH

		cd /home/firefox/
		rm -rf .Xauthority .sndio
		ln -s /home/apple/.Xauthority .Xauthority
		ln -s /home/apple/.sndio .sndio

		usermod -S '' firefox
		if [ -n "`grep -Re '^_Xserver_cookies:' /etc/group`" ]
			then
				GROUPS_FIREFOX="apple,_Xserver_cookies"
			fi
		if [ -n "`grep -Re '^_netbrowser:' /etc/group`" ]
			then
				GROUPS_FIREFOX="${GROUPS_FIREFOX},_netbrowser"
			fi
		if [ -n "`grep -RE '^_sndio_cookies:' /etc/group`" ]
			then
				GROUPS_FIREFOX="${GROUPS_FIREFOX},_sndio_cookies"
			fi
		GROUPS_FIREFOX="`echo "${GROUPS_FIREFOX}" | sed s/^,//g`"
		usermod -G $GROUPS_FIREFOX firefox
	fi

###================ dooble ================###

if [ -n "`grep -Re '^dooble:' /etc/passwd`" -a -d /home/dooble/ ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},dooble
		CH_PATH="/home/dooble/Downloads/"
		chmod -R 770 $CH_PATH

		cd /home/dooble/
		rm -f .Xauthority
		ln -s /home/apple/.Xauthority .Xauthority

		usermod -S '' dooble
		if [ -n "`grep -Re '^_Xserver_cookies:' /etc/group`" ]
			then
				usermod -G apple,_Xserver_cookies dooble
			fi
fi

###================ caven for broadcast with ffmpeg ================###

if [ -n "`grep -Re '^caven:' /etc/group`" -a -d /home/caven/ ]
	then
		GROUPS_APPLE=${GROUPS_APPLE},caven
		CH_PATH="/home/caven/Downloads/"
		chmod -R 770 $CH_PATH

		cd /home/caven/
		rm -rf .Xauthority .sndio
		ln -s /home/apple/.Xauthority .Xauthority
		ln -s /home/apple/.sndio .sndio

		usermod -S '' caven
		if [ -n "`grep -Re '^_Xserver_cookies:' /etc/group`" ]
			then
				GROUPS_CAVEN="apple,_Xserver_cookies"
			fi
		if [ -n "`grep -RE '^_sndio_cookies:' /etc/group`" ]
			then
				GROUPS_CAVEN="${GROUPS_CAVEN},_sndio_cookies"
			fi
		GROUPS_CAVEN="`echo "${GROUPS_CAVEN}" | sed s/^,//g`"
		usermod -G $GROUPS_CAVEN caven
fi

###================ add apple to GROUPS_APPLE ================###

GROUPS_APPLE="`echo "${GROUPS_APPLE}" | sed s/^,//g`"
echo "\n add user: "apple" to group: \n ${GROUPS_APPLE} \n"
usermod -G ${GROUPS_APPLE} apple

###================ set all user's file no executeable ================###

cd $WORK_DIR
LINES_MAX=`sed -n '$'= user.txt`
LINES_MAX=`expr $LINES_MAX + 0`
LINES_COUNTER=`expr 0 + 1`

while [ $LINES_COUNTER -le $LINES_MAX ]
	do
		USER_NAME=`sed -n ${LINES_COUNTER}p user.txt`
		if [ -d /home/${USER_NAME}/ ]
			then
				find /home/${USER_NAME}/ -type f -print0 2>/dev/null | xargs -0 -n 1 -J % chmod a-x %
			fi

	LINES_COUNTER=`expr $LINES_COUNTER + 1`
	done

rm -f /tmp/userinfo.txt /tmp/groupinfo.txt
cat  user.txt | xargs -n 1 -J % userinfo  % >> /tmp/userinfo.txt
cat  user.txt | xargs -n 1 -J % groupinfo % >> /tmp/groupinfo.txt
cat group.txt | xargs -n 1 -J % groupinfo % >> /tmp/groupinfo.txt

