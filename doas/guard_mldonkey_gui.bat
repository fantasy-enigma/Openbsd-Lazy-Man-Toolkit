#! /bin/sh

sleep 1
MODULUS=10

while [ `ps -U apple -o pid -o command | egrep '^ *[0-9]+ /bin/sh /home/BAT/doas/guard_mldonkey_gui\.bat$' | head -n 1 | awk -F ' ' '{printf $1}'` -eq $$ ]
do
	SPY_PROCESSES_LIST="`ps -U mldonkey_gui -o pid -o command | egrep '^ *[0-9]+ ' | \
							egrep -v '^ *[0-9]+ /bin/sh /home/BAT/doas/mldonkey_gui\.bat$' | \
							egrep -v '^ *[0-9]+ /usr/local/bin/mldonkey_gui [(]mlgui[)]$'`"
	if [ -n "$SPY_PROCESSES_LIST" ]
	then
		echo "$SPY_PROCESSES_LIST" | awk -F ' ' '{print $1}' | xargs -n 1 -J % doas -u mldonkey_gui kill -9 %
		notify-send "warring: detected spy on user: mldonkey_gui . processes: $SPY_PROCESSES_LIST"
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
