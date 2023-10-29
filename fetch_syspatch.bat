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
SYSPATCH_DIR="/home/syspatch-${OS_VERSION}-${HW_MACHINE}"

if [ -d "${SYSPATCH_DIR}" ]
then
	echo "system version : ${OS_VERSION}-${HW_MACHINE}"
else
	mkdir "${SYSPATCH_DIR}"
	echo "system version : ${OS_VERSION}-${HW_MACHINE}"
fi

cd ${SYSPATCH_DIR}/
rm -f /home/PKG_CACHE/SHA256-syspatch.sig
doas -u _pkgfetch ftp -o /home/PKG_CACHE/SHA256-syspatch.sig ${PKG_URL}/syspatch/${OS_VERSION}/${HW_MACHINE}/SHA256.sig
chown root:wheel /home/PKG_CACHE/SHA256-syspatch.sig
chmod 444 /home/PKG_CACHE/SHA256-syspatch.sig

rm -f SYSPATCH_SIGNIFY_FAIL.txt
if [ -f SYSPATCH_SIGNIFY_FAIL.txt ]
then 
	echo "can't rm SYSPATCH_SIGNIFY_FAIL.txt, please rm it and try again!"
	exit
elif [ -n "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-syspatch.pub -x /home/PKG_CACHE/SHA256-syspatch.sig 2>/dev/null | grep "^Signature Verified"`" ] 
then
	signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-syspatch.pub -x /home/PKG_CACHE/SHA256-syspatch.sig *.tgz 2>> SYSPATCH_SIGNIFY_FAIL.txt
	cat SYSPATCH_SIGNIFY_FAIL.txt | awk -F ': FAIL' '{print $1}' | xargs -n 1 -J % rm -fv  %
else
	echo "signify SHA256.sig fail"
	exit
fi

rm -f SYSPATCH_SIGNIFY_FAIL.txt
if [ -f SYSPATCH_SIGNIFY_FAIL.txt ]
then 
	echo "can't rm SYSPATCH_SIGNIFY_FAIL.txt, please rm it and try again!"
	exit
elif [ -n "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-syspatch.pub -x /home/PKG_CACHE/SHA256-syspatch.sig 2>/dev/null | grep "^Signature Verified"`" ] 
then
	signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-syspatch.pub -x /home/PKG_CACHE/SHA256-syspatch.sig 2>> SYSPATCH_SIGNIFY_FAIL.txt
else
	echo "signify SHA256.sig fail"
	exit
fi

LINE_MAX=`sed -n $= SYSPATCH_SIGNIFY_FAIL.txt`
LINE_MAX=$(($LINE_MAX+0))
while  [ $LINE_MAX -ge 1 ]
do
	SYSPATCH_NAME="`sed -n ${LINE_MAX}p SYSPATCH_SIGNIFY_FAIL.txt | awk -F ': FAIL' '{print $1}'`"
	doas -u _pkgfetch ftp -o /home/PKG_CACHE/$SYSPATCH_NAME ${PKG_URL}/syspatch/${OS_VERSION}/${HW_MACHINE}/$SYSPATCH_NAME

	LINE_MAX=$(($LINE_MAX-1))
done

chown root:wheel /home/PKG_CACHE/syspatch*.tgz
chmod 444 /home/PKG_CACHE/syspatch*.tgz
cd /home/PKG_CACHE/
signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-syspatch.pub -x /home/PKG_CACHE/SHA256-syspatch.sig *.tgz | grep ": OK$" | awk -F ': OK' '{print $1}' | xargs -n 1 -J % mv -f % ${SYSPATCH_DIR}/
mv /home/PKG_CACHE/SHA256-syspatch.sig ${SYSPATCH_DIR}/
