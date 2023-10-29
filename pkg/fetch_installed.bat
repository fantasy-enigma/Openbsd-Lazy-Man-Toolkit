#! /bin/sh

PARAMETER_OS_VERSION="$1"

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

if [ -n "$PARAMETER_OS_VERSION" ]
then
	if [ -n "`echo $PARAMETER_OS_VERSION | grep -E 'version=[0-9]+\.[0-9]+'`" ]
	then
	OS_VERSION=`echo $PARAMETER_OS_VERSION | awk -F '=' '{print $2}'`
	else
		echo "I don't understand parameter ${PARAMETER_OS_VERSION}"
		exit
	fi
else
	OS_VERSION=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}'`
fi

VERSION_NUMBER=`echo $OS_VERSION | sed 's/[^0-9]//g'`
HW_MACHINE=`sysctl | grep hw.machine= | awk -F '=' '{print $2}'`


doas -u _pkgfetch ftp -o /home/PKG_CACHE/SHA256-stable.sig ${PKG_URL}/${OS_VERSION}/packages-stable/${HW_MACHINE}/SHA256.sig
doas -u _pkgfetch ftp -o /home/PKG_CACHE/SHA256-release.sig ${PKG_URL}/${OS_VERSION}/packages/${HW_MACHINE}/SHA256.sig

cd /home/PKG
if [ "`pwd`" != "/home/PKG" ]
then
	echo "can't cd /home/PKG may be it's not exsist  "
	exit
fi

rm -f ~/PKG_DOWNLOADED_LIST.txt
if [ -f ~/PKG_DOWNLOADED_LIST.txt ]
then 
	echo "can't rm ~/PKG_DOWNLOADED_LIST.txt, please rm it and try again!"
	exit
fi

rm -f ~/PKG_STABLE_LIST.txt
if [ -f ~/PKG_STABLE_LIST.txt ]
then 
	echo "can't rm ~/PKG_STABLE_LIST.txt, please rm it and try again!"
	exit
elif [ -f /home/PKG_CACHE/SHA256-stable.sig ]
then
	if [ -n "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x /home/PKG_CACHE/SHA256-stable.sig 2>/dev/null | grep "^Signature Verified"`" ] 
		then
		echo "signify stable pkg files please wait..."
		cat /home/PKG_CACHE/SHA256-stable.sig | awk -F '(' '{print $2}' | awk -F ')' '{print $1}' >> ~/PKG_STABLE_LIST.txt
		signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x /home/PKG_CACHE/SHA256-stable.sig 2>/dev/null | grep  ': OK' | awk -F ': OK' '{print $1}' >> ~/PKG_DOWNLOADED_LIST.txt
		ls -F SHA256-stable-*.sig | grep -v / | xargs -n 1 -J % signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x % 2>/dev/null | grep ': OK' | awk -F ': OK' '{print $1}' >> ~/PKG_DOWNLOADED_LIST.txt
	else
		echo "signify SHA256.sig fail"
		exit
	fi
else
	echo "" > ~/PKG_STABLE_LIST.txt
fi

rm -f ~/PKG_RELEASE_LIST.txt
if [ -f ~/PKG_RELEASE_LIST.txt ]
then 
	echo "can't rm ~/PKG_RELEASE_LIST.txt, please rm it and try again!"
	exit
elif [ -f /home/PKG_CACHE/SHA256-release.sig ]
then
	if [ -n "`signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x /home/PKG_CACHE/SHA256-release.sig 2>/dev/null | grep "^Signature Verified"`" ] 
	then
		echo "signify release pkg files please wait..."
		cat /home/PKG_CACHE/SHA256-release.sig | awk -F '(' '{print $2}' | awk -F ')' '{print $1}' >> ~/PKG_RELEASE_LIST.txt
		signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x /home/PKG_CACHE/SHA256-release.sig 2>/dev/null | grep  ': OK' | awk -F ': OK' '{print $1}' >> ~/PKG_DOWNLOADED_LIST.txt
	else
		echo "signify SHA256.sig fail"
		exit
	fi
else 
	echo "" > ~/PKG_RELEASE_LIST.txt
fi

rm -f ~/PKG_INSTALLED_LIST.txt
if [ -f ~/PKG_INSTALLED_LIST.txt ]
then
	echo "can't rm ~/PKG_INSTALLED_LIST.txt, please do some things and try again."
	exit
fi

if [ -z "$PARAMETER_OS_VERSION" ]
then
	cd /home/PKG_CACHE/
	pkg_info -q | sed s/$/.tgz/g >> ~/PKG_INSTALLED_LIST.txt

	LINE_MAX=`sed -n $= ~/PKG_INSTALLED_LIST.txt`
	LINE_MAX=$(($LINE_MAX+0))
	while  [ $LINE_MAX -ge 1 ]
	do
		clear
		echo "$LINE_MAX"
		INSTALLED_LINE="`sed -n ${LINE_MAX}p ~/PKG_INSTALLED_LIST.txt`"
		if [ -n "$INSTALLED_LINE" ]
		then
			if [ -z "`cat ~/PKG_DOWNLOADED_LIST.txt | grep "^$INSTALLED_LINE"`" ]
			then
				if [ -n "`cat ~/PKG_STABLE_LIST.txt | grep "^$INSTALLED_LINE"`" ]
				then
					doas -u _pkgfetch ftp ${PKG_URL}/${OS_VERSION}/packages-stable/${HW_MACHINE}/$INSTALLED_LINE
				elif [ -n "`cat ~/PKG_RELEASE_LIST.txt | grep "^$INSTALLED_LINE"`" ]
				then
					doas -u _pkgfetch ftp ${PKG_URL}/${OS_VERSION}/packages/${HW_MACHINE}/$INSTALLED_LINE
				fi
			fi
		fi
		LINE_MAX=$(($LINE_MAX-1))
	done
else
	cd /home/PKG_CACHE/
	pkg_info -qz >> ~/PKG_INSTALLED_LIST.txt

	LINE_MAX=`sed -n $= ~/PKG_INSTALLED_LIST.txt`
	LINE_MAX=$(($LINE_MAX+0))
	while  [ $LINE_MAX -ge 1 ]
	do
		clear
		echo "$LINE_MAX"
		INSTALLED_LINE="`sed -n ${LINE_MAX}p ~/PKG_INSTALLED_LIST.txt | sed s/--.*$/-/g`"
		if [ -n "$INSTALLED_LINE" ]
		then
			if [ -z "`cat ~/PKG_DOWNLOADED_LIST.txt | grep -E "^${INSTALLED_LINE}[0-9]+"`" ]
			then
				if [ -n "`cat ~/PKG_STABLE_LIST.txt | grep -E "^${INSTALLED_LINE}[0-9]+"`" ]
				then
					cat ~/PKG_STABLE_LIST.txt | grep -E "^${INSTALLED_LINE}[0-9]+" | xargs -n 1 -I {_PKG_NAME_} doas -u _pkgfetch ftp ${PKG_URL}/${OS_VERSION}/packages-stable/${HW_MACHINE}/{_PKG_NAME_}
				elif [ -n "`cat ~/PKG_RELEASE_LIST.txt | grep -E "^${INSTALLED_LINE}[0-9]+"`" ]
				then
					cat ~/PKG_RELEASE_LIST.txt | grep -E "^${INSTALLED_LINE}[0-9]+" | xargs -n 1 -I {_PKG_NAME_} doas -u _pkgfetch ftp ${PKG_URL}/${OS_VERSION}/packages/${HW_MACHINE}/{_PKG_NAME_} 
				fi
			fi
		fi
		LINE_MAX=$(($LINE_MAX-1))
	done

### download depend pkg ###

	rm -f ~/PKG_DEPEND_LIST.txt
	if [ -f ~/PKG_DEPEND_LIST.txt ]
	then
		echo " Can't rm ~/PKG_DEPEND_LIST.txt "
		exit
	fi

	rm -f ~/PKG_DEPEND_LIST_NEW.txt
	if [ -f ~/PKG_DEPEND_LIST_NEW.txt ]
	then
		echo " Can't rm ~/PKG_DEPEND_LIST_NEW.txt "
		exit
	fi

	echo "create depend files list..."
	cd /home/PKG/
	cat ~/PKG_DOWNLOADED_LIST.txt | xargs -n 1 -J % pkg_info -f % | grep -E ^@depend | awk -F ':' '{print $NF}' | sed s/$/.tgz/g >> ~/PKG_DEPEND_LIST.txt

	LINE_MAX=`sed -n '$'= ~/PKG_DEPEND_LIST.txt`
	while [ $LINE_MAX -gt 0 ]
	do
		clear
		echo "remove duplicate files list...\n ${LINE_MAX}"

		LINE_PKG_DEPEND_LIST="`sed -n ${LINE_MAX}p ~/PKG_DEPEND_LIST.txt`"
		if [ -n "$LINE_PKG_DEPEND_LIST" ]
		then
			if [ -z "`cat ~/PKG_DEPEND_LIST_NEW.txt | grep $LINE_PKG_DEPEND_LIST`" ]
			then
				echo "$LINE_PKG_DEPEND_LIST" >> ~/PKG_DEPEND_LIST_NEW.txt
			fi
		fi
	LINE_MAX=$(($LINE_MAX-1))
	done
	mv ~/PKG_DEPEND_LIST_NEW.txt ~/PKG_DEPEND_LIST.txt

	LINE_MAX=`sed -n '$'= ~/PKG_DEPEND_LIST.txt`
	while [ $LINE_MAX -gt 0 ]
	do
		clear
		echo "remove downloaded files list...\n ${LINE_MAX}"

		LINE_PKG_DEPEND_LIST="`sed -n ${LINE_MAX}p ~/PKG_DEPEND_LIST.txt`"
		if [ -n "$LINE_PKG_DEPEND_LIST" ]
		then
			if [ -z "`cat ~/PKG_DOWNLOADED_LIST.txt | grep $LINE_PKG_DEPEND_LIST`" ]
			then
				echo "$LINE_PKG_DEPEND_LIST" >> ~/PKG_DEPEND_LIST_NEW.txt
			fi
		fi
	LINE_MAX=$(($LINE_MAX-1))
	done
	mv ~/PKG_DEPEND_LIST_NEW.txt ~/PKG_DEPEND_LIST.txt

	cd /home/PKG_CACHE/
	LINE_MAX=`sed -n $= ~/PKG_DEPEND_LIST.txt`
	LINE_MAX=$(($LINE_MAX+0))
	while  [ $LINE_MAX -ge 1 ]
	do
		clear
		echo "$LINE_MAX"
		LINE_DEPEND="`sed -n ${LINE_MAX}p ~/PKG_DEPEND_LIST.txt`"
		if [ -n "$LINE_DEPEND" ]
		then
			if [ -z "`cat ~/PKG_DOWNLOADED_LIST.txt | grep -E "^${LINE_DEPEND}"`" ]
			then
				if [ -n "`cat ~/PKG_STABLE_LIST.txt | grep -E "^${LINE_DEPEND}"`" ]
				then
					cat ~/PKG_STABLE_LIST.txt | grep -E "^${LINE_DEPEND}" | xargs -n 1 -I {_PKG_NAME_} doas -u _pkgfetch ftp ${PKG_URL}/${OS_VERSION}/packages-stable/${HW_MACHINE}/{_PKG_NAME_}
				elif [ -n "`cat ~/PKG_RELEASE_LIST.txt | grep -E "^${LINE_DEPEND}"`" ]
				then
					cat ~/PKG_RELEASE_LIST.txt | grep -E "^${LINE_DEPEND}" | xargs -n 1 -I {_PKG_NAME_} doas -u _pkgfetch ftp ${PKG_URL}/${OS_VERSION}/packages/${HW_MACHINE}/{_PKG_NAME_} 
				fi
			fi
		fi
		LINE_MAX=$(($LINE_MAX-1))
	done

fi

