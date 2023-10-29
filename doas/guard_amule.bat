#! /bin/sh

sleep 1
MODULUS=10

while [ `ps -U apple -o pid -o command | egrep '^ *[0-9]+ /bin/sh /home/BAT/doas/guard_amule\.bat$' | head -n 1 | awk -F ' ' '{printf $1}'` -eq $$ ]
do
	SPY_PROCESSES_LIST="`ps -U amule -o pid -o command | egrep '^ *[0-9]+ ' | \
							egrep -v '^ *[0-9]+ /bin/sh /home/BAT/doas/amule\.bat$' | \
                        egrep -v '^ *[0-9]+ /usr/local/bin/amule$' | \
							egrep -v '^ *[0-9]+ dbus-launch ' | \
							egrep -v '^ *[0-9]+ /usr/local/bin/dbus-daemon '`"
	if [ -n "$SPY_PROCESSES_LIST" ]
	then
		echo "$SPY_PROCESSES_LIST" | awk -F ' ' '{print $1}' | xargs -n 1 -J % doas -u amule kill -9 %
		notify-send "warring: detected spy on user: amule . processes: $SPY_PROCESSES_LIST"
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
	sleep 0.$(($RANDOM%$MODULUS))$(($RANDOM%$MODULUS))$(($RANDOM%$MODULUS))
done
