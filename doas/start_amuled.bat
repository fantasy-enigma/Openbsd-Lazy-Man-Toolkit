#! /bin/sh

while [ true ]
do
	sleep 3
	if [ -z "`ps -U amuled -o command | grep '^/bin/sh /home/BAT/doas/amuled\.bat$'`" -a -z "`ps -U amuled -o command | grep '^/usr/local/bin/amuled$'`" ]
	then
		AMULE_PORT=$RANDOM
		while [ $AMULE_PORT -lt 5000 -o $AMULE_PORT -gt 65535 ]
		do
			AMULE_PORT=$RANDOM
		done
		sed -i s/'^Port=[0-9]*$'/"Port=$AMULE_PORT"/g /home/amuled/.aMule/amule.conf

		AMULE_PORT=$RANDOM
		while [ $AMULE_PORT -lt 5000 -o $AMULE_PORT -gt 65535 ]
		do
			AMULE_PORT=$RANDOM
		done
		sed -i s/'^UDPPort=[0-9]*$'/"UDPPort=$AMULE_PORT"/g /home/amuled/.aMule/amule.conf

		while [ true ]
		do
			KEY_OBFUSCATION=$RANDOM
			while [ true ]
			do
				KEY_OBFUSCATION=$((${KEY_OBFUSCATION}*10+$RANDOM))
				if [ $KEY_OBFUSCATION -ge 1000000000 ]
				then
					break
				fi
			done

			KEY_OBFUSCATION=$(($KEY_OBFUSCATION%4294967296))
			if [ KEY_OBFUSCATION -ge 1000000000 ]
			then 
				break
			fi
		done
		sed -i s/'CryptoKadUDPKey=[0-9]*$'/"CryptoKadUDPKey=${KEY_OBFUSCATION}"/g /home/amuled/.aMule/amule.conf

		if [ -n "`cat /home/amuled/.aMule/SHAREDDIR_SCAN.TXT`" ]
			then
				echo '' > /home/amuled/.aMule/shareddir.dat
				cat /home/amuled/.aMule/SHAREDDIR_SCAN.TXT | grep -v '^$' | xargs -n 1 -J % find % -type d 2>/dev/null | sed s/'$'/'\/'/g >> /home/amuled/.aMule/shareddir.dat
			fi

		notify-send "run emule at `date`"
		doas -u amuled /home/BAT/doas/amuled.bat
	fi
done
