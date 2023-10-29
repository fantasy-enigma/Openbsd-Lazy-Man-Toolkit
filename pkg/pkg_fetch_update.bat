#! /bin/sh

LINE_MAX=`sed -n $= /etc/installurl`
LINE_MAX=$(($LINE_MAX+0))

while [ $LINE_MAX -ge 1 ]
do
	PKG_URL=`sed -n ${LINE_MAX}p /etc/installurl | grep -v ' ' | grep -v '#'`

	if [ -n "$PKG_URL" ]
	then
		break
	fi
	
	LINE_MAX=$(($LINE_MAX-1))
done

if [ -z "$PKG_URL" ]
then
	echo "no installurl, please set it in /etc/installurl"
	exit
fi

HW_MACHINE=`sysctl | grep hw.machine= | awk -F '=' '{print $2}'`
OS_VERSION=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}'`
VERSION_NUMBER=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}' | sed 's/[^0-9]//g'`

doas -u _pkgfetch ftp -o /home/PKG_CACHE/SHA256-stable.sig ${PKG_URL}/${OS_VERSION}/packages-stable/${HW_MACHINE}/SHA256.sig
# doas -u _pkgfetch ftp -o /home/PKG_CACHE/SHA256-stable.sig ${PKG_URL}/${OS_VERSION}/packages/${HW_MACHINE}/SHA256.sig

rm -f ~/PKG_STABLE_LIST.txt
if [ -f ~/PKG_STABLE_LIST.txt ]
then 
	echo "can't rm ~/PKG_STABLE_LIST.txt, please rm it and try again!"
	exit
elif [ -n "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x /home/PKG_CACHE/SHA256-stable.sig 2>/dev/null | grep "^Signature Verified"`" ] 
then
	cat /home/PKG_CACHE/SHA256-stable.sig | awk -F '(' '{print $2}' | awk -F ')' '{print $1}' >> ~/PKG_STABLE_LIST.txt
else
	echo "signify SHA256.sig fail"
	exit
fi

QUIRKS=`cat ~/PKG_STABLE_LIST.txt | grep quirks-`
if [ -n "$QUIRKS" ]
then
	doas pkg_add $QUIRKS 
fi

rm -f ~/PKG_INSTALLED_LIST.txt
if [ -f ~/PKG_INSTALLED_LIST.txt ]
then
	echo "can't rm ~/PKG_INSTALLED_LIST.txt, please do some things and try again."
	exit
fi
pkg_info -q | sed s/$/.tgz/g >> ~/PKG_INSTALLED_LIST.txt

#regular_expression
REGULAR_EXPRESSION=''-[0-9]+(\.[0-9]+)*(p[0-9]+)?(v[0-9]+)?(-|\.tgz)''

LINE_MAX=`sed -n $= ~/PKG_STABLE_LIST.txt`
LINE_MAX=$(($LINE_MAX+0))
while  [ $LINE_MAX -ge 1 ]
do
	FLAG_PKG_NEED_UPDATE=0
	if [ -n "`sed -n ${LINE_MAX}p ~/PKG_STABLE_LIST.txt`" ]
	then
		STABLE_NAME=`sed -n ${LINE_MAX}p ~/PKG_STABLE_LIST.txt | awk -F $REGULAR_EXPRESSION '{print $1}'`
		MODULAR=`sed -n ${LINE_MAX}p ~/PKG_STABLE_LIST.txt | awk -F $REGULAR_EXPRESSION '{print $2}' | sed s/\.tgz//g`

		if [ -n "$MODULAR" ]
		then
			PKG_INSTALLED=`cat ~/PKG_INSTALLED_LIST.txt | grep "^$STABLE_NAME\-[0-9]" | grep "\-${MODULAR}\.tgz"`
		else
			PKG_INSTALLED=`cat ~/PKG_INSTALLED_LIST.txt | grep "^$STABLE_NAME\-[0-9]"`
		fi

		if [ -n "$PKG_INSTALLED" ]
		then
			if [ -n "$MODULAR" ]
			then
				STABLE_VERSION=`sed -n ${LINE_MAX}p ~/PKG_STABLE_LIST.txt | sed s/$STABLE_NAME//g | sed s/$MODULAR//g | sed s/.tgz//g | sed s/-//g`
				INSTALLED_VERSION=`echo $PKG_INSTALLED | sed s/$STABLE_NAME//g | sed s/$MODULAR//g | sed s/.tgz//g | sed s/-//g | awk -F ' ' '{print $NF}'`
			else
				STABLE_VERSION=`sed -n ${LINE_MAX}p ~/PKG_STABLE_LIST.txt | sed s/$STABLE_NAME//g | sed s/.tgz//g | sed s/-//g`
				INSTALLED_VERSION=`echo $PKG_INSTALLED | sed s/$STABLE_NAME//g | sed s/.tgz//g | sed s/-//g | awk -F ' ' '{print $NF}'`
			fi
		else
			INSTALLED_VERSION=""
		fi

		
		clear
		echo "$LINE_MAX : "
		if [ -n "$INSTALLED_VERSION" -a -n "$STABLE_VERSION" ]
		then
			echo "${STABLE_NAME}**${MODULAR} : ${INSTALLED_VERSION}\n${STABLE_NAME}**${MODULAR} : ${STABLE_VERSION}"
			INSTALLED_VERSION_NUMBER=`echo $INSTALLED_VERSION | awk -F '(p|v)' '{print $1}'`
			INSTALLED_P_NUMBER=`echo $INSTALLED_VERSION | awk -F 'p' '{print $2}' | awk -F 'v' '{print $1}'`
			INSTALLED_V_NUMBER=`echo $INSTALLED_VERSION | awk -F 'v' '{print $2}' | awk -F 'p' '{print $1}'`

			STABLE_VERSION_NUMBER=`echo $STABLE_VERSION | awk -F '(p|v)' '{print $1}'`
			STABLE_P_NUMBER=`echo $STABLE_VERSION | awk -F 'p' '{print $2}' | awk -F 'v' '{print $1}'`
			STABLE_V_NUMBER=`echo $STABLE_VERSION | awk -F 'v' '{print $2}' | awk -F 'p' '{print $1}'`

			SUBVERSION_COUNTER=$((0+1))
			while [ ture ]
			do

				INSTALLED_SUB_VERSION=`echo $INSTALLED_VERSION_NUMBER | awk -F '.' "{print $"$SUBVERSION_COUNTER"}"`
				STABLE_SUB_VERSION=`echo $STABLE_VERSION_NUMBER | awk -F '.' "{print $"$SUBVERSION_COUNTER"}"`

				echo "$INSTALLED_SUB_VERSION <=> $STABLE_SUB_VERSION"

				if [ -n "$INSTALLED_SUB_VERSION" -a -n "$STABLE_SUB_VERSION" ]
				then		
					if [ $STABLE_SUB_VERSION -gt $INSTALLED_SUB_VERSION ]
					then
						FLAG_PKG_NEED_UPDATE=1
						break
					fi
					
					if [ $STABLE_SUB_VERSION -lt $INSTALLED_SUB_VERSION ]
					then
						break
					fi
				fi

				if [ -z "$INSTALLED_SUB_VERSION" -a -n "$STABLE_SUB_VERSION" ]
				then	
					FLAG_PKG_NEED_UPDATE=1
					break
				fi

				if [ -n "$INSTALLED_SUB_VERSION" -a -z "$STABLE_SUB_VERSION" ]
				then
					break
				fi

				if [ -z "$INSTALLED_SUB_VERSION" -a -z "$STABLE_SUB_VERSION" ]
				then
					echo "p${INSTALLED_P_NUMBER} <=> p${STABLE_P_NUMBER}\nv${INSTALLED_V_NUMBER} <=> v${STABLE_V_NUMBER}"
					if [ -z "$INSTALLED_P_NUMBER" -a -n "$STABLE_P_NUMBER" ]
					then
						FLAG_PKG_NEED_UPDATE=1
						break
					fi

					if [ -z "$INSTALLED_P_NUMBER" -a -z "$STABLE_P_NUMBER" ]
					then
						if [ -z "$INSTALLED_V_NUMBER" -a -n "$STABLE_V_NUMBER" ]
						then
							FLAG_PKG_NEED_UPDATE=1
							break
						fi

						if [ -n "$INSTALLED_V_NUMBER" -a -n "$STABLE_V_NUMBER" ]
						then
							if [ $INSTALLED_V_NUMBER -lt $STABLE_V_NUMBER ]
							then
								FLAG_PKG_NEED_UPDATE=1
								break
							fi
						fi
					fi

					if [ -n "$INSTALLED_P_NUMBER" -a -n "$STABLE_P_NUMBER" ]
					then
						if [ $INSTALLED_P_NUMBER -lt $STABLE_P_NUMBER ]
						then
							FLAG_PKG_NEED_UPDATE=1
							break
						fi

						if [ $INSTALLED_P_NUMBER -eq $STABLE_P_NUMBER ]
						then
							if [ -z "$INSTALLED_V_NUMBER" -a -n "$STABLE_V_NUMBER" ]
							then
								FLAG_PKG_NEED_UPDATE=1
								break
							fi

							if [ -n "$INSTALLED_V_NUMBER" -a -n "$STABLE_V_NUMBER" ]
							then
								if [ $INSTALLED_V_NUMBER -lt $STABLE_V_NUMBER ]
								then
									FLAG_PKG_NEED_UPDATE=1
									break
								fi
							fi
						fi
					fi
					break
				fi

				SUBVERSION_COUNTER=$(($SUBVERSION_COUNTER+1))
			done
		fi


	fi

	if [ FLAG_PKG_NEED_UPDATE -eq 1 ]
	then
		if [ -n "$MODULAR" ]
		then
			doas -u caven -o /home/PKG_CACHE/${STABLE_NAME}-${STABLE_VERSION}-${MODULAR}.tgz ${PKG_URL}/${OS_VERSION}/packages-stable/${STABLE_NAME}-${STABLE_VERSION}-${MODULAR}.tgz
		else
			doas -u caven -o /home/PKG_CACHE/${STABLE_NAME}-${STABLE_VERSION}.tgz ${PKG_URL}/${OS_VERSION}/packages-stable/${STABLE_NAME}-${STABLE_VERSION}.tgz
		fi
	fi

	LINE_MAX=$(($LINE_MAX-1))
done
