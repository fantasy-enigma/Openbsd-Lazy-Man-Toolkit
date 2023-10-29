#! /bin/sh

umask 007

AMULE_PORT=$RANDOM
while [ $AMULE_PORT -lt 5000 -o $AMULE_PORT -gt 65535 ]
do
	AMULE_PORT=$RANDOM
done
sed -i s/'^Port=[0-9]*$'/"Port=$AMULE_PORT"/g ~/.aMule/amule.conf

AMULE_PORT=$RANDOM
while [ $AMULE_PORT -lt 5000 -o $AMULE_PORT -gt 65535 ]
do
	AMULE_PORT=$RANDOM
done
sed -i s/'^UDPPort=[0-9]*$'/"UDPPort=$AMULE_PORT"/g ~/.aMule/amule.conf

while [ true ]
do
	KEY_OBFUSCATION=$RANDOM
	while [ true ]
	do
		KEY_OBFUSCATION=$((${KEY_OBFUSCATION}*10+$RANDOM))
		if [ $KEY_OBFUSCATION -gt 999999999 ]
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
sed -i s/'CryptoKadUDPKey=[0-9]*$'/"CryptoKadUDPKey=${KEY_OBFUSCATION}"/g ~/.aMule/amule.conf

/usr/local/bin/amule
