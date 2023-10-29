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

cd /home/PKG_CACHE/
if [ "`pwd`" != "/home/PKG_CACHE" ]
then
	echo "can't cd /home/PKG_CACHE"
	exit
fi


if [ -n "$1" -a  -n "`echo $1 | grep -E '^version=[0-9]+\.[0-9]+$'`" ]
then
	OS_VERSION=`echo $1 | awk -F '=' '{print $2}'`
else
	OS_VERSION=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}'`
fi

VERSION_NUMBER=`echo $OS_VERSION | sed 's/[^0-9]//g'`
HW_MACHINE=`sysctl | grep hw.machine= | awk -F '=' '{print $2}'`

# HW_MACHINE=`sysctl | grep hw.machine= | awk -F '=' '{print $2}'`
# OS_VERSION=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}'`
# VERSION_NUMBER=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}' | sed 's/[^0-9]//g'`
# echo "${HW_MACHINE} \n ${OS_VERSION} \n ${VERSION_NUMBER}"

if [ -n "$1" -a "$1" = "online" ]
then
	rm -f SHA256-stable.sig
	rm -f SHA256-release.sig
	doas -u _pkgfetch ftp -o SHA256-stable.sig ${PKG_URL}/${OS_VERSION}/packages-stable/${HW_MACHINE}/SHA256.sig
	doas -u _pkgfetch ftp -o SHA256-release.sig ${PKG_URL}/${OS_VERSION}/packages/${HW_MACHINE}/SHA256.sig
fi
chown root:wheel *.sig *.tgz
chmod 444 *.sig *.tgz

if [ -f "SHA256-stable.sig" ]
then
	if [ -n "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x SHA256-stable.sig 2>/dev/null | grep ': OK' | awk -F ': OK' '{print $1}' | xargs -n 1 -J % mv -v % /home/PKG/ 2>/dev/null | grep \>`" ]
	then
		SHA256_STABLE_TIME="`ls -lT SHA256-stable.sig | awk -F ' ' '{print $6"-"$7"-"$8"-"$9}' | sed 's/\:/./g'`"
		mv SHA256-stable.sig /home/PKG/SHA256-stable-${SHA256_STABLE_TIME}.sig
	elif [ -z "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x SHA256-stable.sig 2>/dev/null | grep "^Signature Verified"`" ]
	then
		echo "Warring! signify fail: SHA256-stable.sig"
	fi
fi

rm -f SIG_FILES_LIST.TXT
ls -F *.sig | grep -v / >> SIG_FILES_LIST.TXT
LINE_MAX=`sed -n $= SIG_FILES_LIST.TXT`
LINE_MAX=$(($LINE_MAX+0))
while [ $LINE_MAX -ge 1 ]
do
	SIG_FILE_NAME=`sed -n ${LINE_MAX}p SIG_FILES_LIST.TXT`
	if [ -n "$SIG_FILE_NAME" ]
	then
		if [ -n "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x $SIG_FILE_NAME 2>/dev/null | grep ': OK' | awk -F ': OK' '{print $1}' | xargs -n 1 -J % mv -v % /home/PKG/ 2>/dev/null | grep \>`" ]
		then
			mv ${SIG_FILE_NAME} /home/PKG/
		elif [ -z "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x $SIG_FILE_NAME 2>/dev/null | grep "^Signature Verified"`" ]
		then
			echo "Warring! signify fail: $SIG_FILE_NAME"
		fi
	fi
	LINE_MAX=$(($LINE_MAX-1))
done

chown -R root:wheel /home/PKG/
chmod -R 755 /home/PKG/
chmod -R 444 /home/PKG/*.tgz
chmod -R 444 /home/PKG/*.sig

