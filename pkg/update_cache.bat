#! /bin/sh

export PKG_PATH=/home/PKG/
export PKG_CACHE=/home/PKG_CACHE/

rm -f ~/PKG_INSTALLED_LIST.txt
if [ -f ~/PKG_INSTALLED_LIST.txt ]
then
	echo "can't rm ~/PKG_INSTALLED_LIST.txt, please do some things and try again."
	exit
fi
pkg_info -z >> ~/PKG_INSTALLED_LIST.txt


rm -f ~/PKG_STABLE_LIST.txt
rm -f ~/PKG_STABLE_LIST.txt
if [ -f ~/PKG_STABLE_LIST.txt ]
then
	echo "can't rm ~/PKG_STABLE_LIST.txt, please do some things and try again."
	exit
fi

HW_MACHINE=`sysctl | grep hw.machine= | awk -F '=' '{print $2}'`
OS_VERSION=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}'`
VERSION_NUMBER=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}' | sed 's/[^0-9]//g'`

cd /home/PKG
ls -F SHA256-stable-*.sig | grep -v $/ | xargs -n 1 -J % signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x % 2>/dev/null | grep ': OK' | awk -F ': OK' '{print $1}' >> ~/PKG_STABLE_LIST.txt


LINE_MAX=`sed -n $= ~/PKG_INSTALLED_LIST.txt`
LINE_MAX=$(($LINE_MAX+0))
while  [ $LINE_MAX -ge 1 ]
do
	LINE_INSTALLED="`sed -n ${LINE_MAX}p ~/PKG_INSTALLED_LIST.txt`"
	clear
	echo "${LINE_MAX}:\n${LINE_INSTALLED}"
	if [ -n "$LINE_INSTALLED" -a -n "`grep -Re "^$(echo $LINE_INSTALLED | sed s/--.*/-/g)" ~/PKG_STABLE_LIST.txt`" ]
	then
		doas pkg_add $LINE_INSTALLED
	fi

LINE_MAX=$(($LINE_MAX-1))
done

export PKG_PATH=
export PKG_CACHE=

