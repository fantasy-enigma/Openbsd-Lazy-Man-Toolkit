#! /bin/sh

HW_MACHINE=`sysctl | grep hw.machine= | awk -F '=' '{print $2}'`
OS_VERSION=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}'`
VERSION_NUMBER=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}' | sed 's/[^0-9]//g'`
SYSPATCH_DIR="/home/syspatch-${OS_VERSION}-${HW_MACHINE}/"

while [ -n "`ps -A | grep reorder_kernel | grep -v grep`" ]
do
	clear
	echo "another link_kernel progress is running, please wait..."
	sleep 1
done

if [ -d "$SYSPATCH_DIR" ]
then
	cd $SYSPATCH_DIR
	if [ -f SHA256-syspatch.sig ]
	then
		signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-syspatch.pub -x SHA256-syspatch.sig | grep ": OK" | awk -F ': OK' '{print $1}' | xargs -n 1 -J % tar -pxzf % -C /
		sync
		sh /usr/libexec/reorder_kernel
		sync
		ls -lF /var/syspatch/
	else
		echo "can't find SHA256-syspatch.sig"
		exit
	fi
else
	echo "can't cd $SYSPATCH_DIR"
	exit
fi
