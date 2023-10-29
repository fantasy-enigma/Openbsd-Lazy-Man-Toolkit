#! /bin/sh

sleep 1
MODULUS=10
USER_DOAS=caven

while [ `ps -U apple -o pid -o command | egrep '^ *[0-9]+ /bin/sh /home/BAT/doas/guard_ffmpeg\.bat$' | head -n 1 | awk -F ' ' '{printf $1}'` -eq $$ ]
do
	SPY_PROCESSES_LIST="`ps -U $USER_DOAS -o pid -o command | egrep '^ *[0-9]+ ' | \
                        egrep -v '^ *[0-9]+ /bin/sh /home/BAT/doas/ffmpeg\.bat ' | \
                        egrep -v '^ *[0-9]+ /usr/local/bin/ffmpeg ' | \
                        egrep -v '^ *[0-9]+ smplayer$' | \
                        egrep -v '^ *[0-9]+ /usr/local/bin/mpv ' | \
                        egrep -v '^ *[0-9]+ firefox-esr$' | \
                        egrep -v '^ *[0-9]+ dbus-launch ' | \
                        egrep -v '^ *[0-9]+ /usr/local/bin/dbus-daemon ' | \
                        egrep -v '^ *[0-9]+ /usr/local/libexec/dconf-service$' | \
                        egrep -v '^ *[0-9]+ /usr/local/lib/firefox-esr/firefox-esr '`"
	if [ -n "$SPY_PROCESSES_LIST" ]
	then
		echo "$SPY_PROCESSES_LIST" | awk -F ' ' '{print $1}' | xargs -n 1 -J % doas -u $USER_DOAS kill -9 %
		notify-send "warring: detected spy on user: $USER_DOAS . processes: $SPY_PROCESSES_LIST"
		if [ $MODULUS -gt 1 ]
		then
			MODULUS=$(($MODULUS-1))
		fi
	else
		if [ $MODULUS -lt 10 ]
		then
			MODULUS=$(($MODULUS+1))
		fi
	fi


	if [ -n "`grep -Re "Failed to query xcb pointer" /home/$USER_DOAS/ffmpeg_err.txt`" ]
	then
		ps -U $USER_DOAS -o pid -o command | egrep '^ *[0-9]+ /usr/local/bin/ffmpeg ' | awk -F ' ' '{print $1}' | xargs -n 1 -J % doas -u $USER_DOAS kill -9 %
	fi

	sleep 0.$(($RANDOM%$MODULUS))$(($RANDOM%$MODULUS))$(($RANDOM%$MODULUS))
done
