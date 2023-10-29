#! /bin/sh


while [ "`ps -U $USER -o pid -o command | grep '^ *[0-9]* /bin/sh /home/BAT/doas/start_amuled.bat$'`" ]
do
	kill `ps -U $USER -o pid -o command | grep '^ *[0-9]* /bin/sh /home/BAT/doas/start_amuled.bat$'  | awk -F ' ' '{print $1}'`
	sleep 1
done

while [ "`ps -U amule -o pid | grep -v '  PID'`" ]
do
	ps -U amule -o pid | grep -v '  PID' | awk -F ' ' '{print $1}' | xargs -n 1 -J % doas -u amule kill %
	sleep 1
done

while [ "`ps -U amuled -o pid | grep -v '  PID'`" ]
do
	ps -U amuled -o pid | grep -v '  PID' | awk -F ' ' '{print $1}' | xargs -n 1 -J % doas -u amuled kill %
	sleep 1
done
