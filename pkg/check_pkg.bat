#! /bin/sh

FLAG_NO_CHECK="$1"
VERSION_NUMBER=`sysctl | grep kern.version= | awk -F ' ' '{print $2}' | sed 's/[^0-9]//g'`

cd /home/PKG/
if [ "`pwd`" != /home/PKG ]
then
	echo "can't cd /home/PKG"
	exit
fi

rm -f PKG_INSTALLED_LIST.TXT
if [ -f PKG_INSTALLED_LIST.TXT ]
then
	echo "can't rm PKG_INSTALLED_LIST.TXT"
	exit
fi

rm -f PKG_CHECK_LOG.TXT
if [ -f PKG_CHECK_LOG.TXT ]
then
	echo "can't rm PKG_CHECK_LOG.TXT"
	exit
fi

rm -f CACHE_CHECK_OK.txt
if [ -f CACHE_CHECK_OK.txt ]
then
	echo "can't rm CACHE_CHECK_OK.txt, please rm it and try again!"
	exit
fi

echo "signify...please wait."
ls -F SHA256*.sig | grep -v / | xargs -n 1 -J % signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x % 2>/dev/null | grep ': OK' | awk -F ': OK' '{print $1}' >> CACHE_CHECK_OK.txt

pkg_info | awk -F ' ' '{print $1}' >> PKG_INSTALLED_LIST.TXT
PKG_MAX=`sed -n '$'= PKG_INSTALLED_LIST.TXT`
PKG_COUNTER=1
while [ $PKG_COUNTER -le $PKG_MAX ]
do
	PKG_INSTALLED_NAME=`sed -n ${PKG_COUNTER}p PKG_INSTALLED_LIST.TXT`
	if [ -n "$PKG_INSTALLED_NAME" ]
	then
		if [ -n "`cat CACHE_CHECK_OK.txt | grep  "^${PKG_INSTALLED_NAME}.tgz"`" ]
		then
			clear
			echo "${PKG_COUNTER}:${PKG_MAX} \n${PKG_INSTALLED_NAME}.tgz"
			tar -xzf ${PKG_INSTALLED_NAME}.tgz +CONTENTS
			chown root:wheel +CONTENTS
			chmod 644 +CONTENTS
			if [ -z "`mv -fv +CONTENTS /var/db/pkg/${PKG_INSTALLED_NAME}/ 2>/dev/null | grep \>`" ]
			then
				echo "can't uncompress ${PKG_INSTALLED_NAME}.tgz/+CONTENTS file  lost exit !"
				exit
			fi
		else
			echo "pkg file ${PKG_INSTALLED_NAME}.tgz lost exit !"
			exit
		fi
	fi
	sync
	PKG_COUNTER=$(($PKG_COUNTER +1))
done

if [ "$FLAG_NO_CHECK" = "nocheck" ]
then
	echo "NO_CHECK mode only restore +CONTENTS , may be you need run pkg_check manual."
	exit
else
	echo "now pkg_check please wait..."
	pkg_check -FI >> PKG_CHECK_LOG.TXT
	echo "finish, please read /home/PKG/PKG_CHECK_LOG.TXT"
fi
