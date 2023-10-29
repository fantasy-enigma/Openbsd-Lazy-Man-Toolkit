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

