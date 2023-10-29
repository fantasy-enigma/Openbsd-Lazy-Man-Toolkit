#! /bin/sh

export PKG_CACHE=/home/PKG_CACHE/

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


rm -f ~/PKG_INSTALLED_LIST.txt
if [ -f ~/PKG_INSTALLED_LIST.txt ]
then
	echo "can't rm ~/PKG_INSTALLED_LIST.txt, please do some things and try again."
	exit
fi
pkg_info -z >> ~/PKG_INSTALLED_LIST.txt


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


LINE_MAX=`sed -n $= ~/PKG_INSTALLED_LIST.txt`
LINE_MAX=$(($LINE_MAX+0))
while  [ $LINE_MAX -ge 1 ]
do
	LINE_INSTALLED="`sed -n ${LINE_MAX}p ~/PKG_INSTALLED_LIST.txt`"
	clear
	echo "${LINE_MAX}:\n${LINE_INSTALLED}"
	if [ -n "$LINE_INSTALLED" -a -n "`grep -Re "^$(echo $LINE_INSTALLED | sed s/--.*/-/g)" ~/PKG_STABLE_LIST.txt`" ]
	then
		doas pkg_add -z $LINE_INSTALLED
	fi

LINE_MAX=$(($LINE_MAX-1))
done

export PKG_CACHE=
