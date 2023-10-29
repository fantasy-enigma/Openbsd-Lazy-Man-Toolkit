#! /bin/sh

VERSION_NUMBER=`sysctl | grep kern.osrelease= | awk -F '=' '{print $2}' | sed 's/[^0-9]//g'`
WK_DIR=`pwd`

rm -rf ~/PKG_NEED_INSTALL
if [ -d ~/PKG_NEED_INSTALL ]
then
	echo "can't rm ~/PKG_NEED_INSTALL"
	exit
else
	mkdir ~/PKG_NEED_INSTALL
	if [ -d ~/PKG_NEED_INSTALL ]
	then
		echo "create empty direct ~/PKG_NEED_INSTALL"
	else
		echo "can't create direct ~/PKG_NEED_INSTALL : file Name conflict"
		exit
	fi
fi

rm -f ~/UPDATE_CACHE_ERROR_LOG.txt
if [ -f ~/UPDATE_CACHE_ERROR_LOG.txt ]
then
	echo "can't rm ~/UPDATE_CACHE_ERROR_LOG.txt, please do some things and try again."
	exit
fi

rm -f ~/PKG_INSTALLED_LIST.txt
if [ -f ~/PKG_INSTALLED_LIST.txt ]
then
	echo "can't rm ~/PKG_INSTALLED_LIST.txt \n"
	exit
fi
pkg_info -q >> ~/PKG_INSTALLED_LIST.txt

rm -f ~/CACHE_CHECK_OK.txt
if [ -f ~/CACHE_CHECK_OK.txt ]
then
	echo "can't rm ~/CACHE_CHECK_OK.txt \n"
	exit
fi

echo "signify...please wait."

cd /home/PKG/
ls -F *.sig | grep -v $/ | xargs -n 1 -J % signify -Cp /etc/signify/openbsd-${VERSION_NUMBER}-pkg.pub -x % 2>/dev/null | grep ': OK$' | awk -F ': OK' '{print $1}' >> ~/CACHE_CHECK_OK.txt

cat ~/CACHE_CHECK_OK.txt | grep quirks | xargs -n 1 -I {_name_} ln {_name_} ~/PKG_NEED_INSTALL/{_name_}

LINE_MAX=`sed -n $= ~/CACHE_CHECK_OK.txt`
LINE_MAX=$(($LINE_MAX+0))

while  [ $LINE_MAX -ge 1 ]
do
	if [ -n "`sed -n ${LINE_MAX}p ~/CACHE_CHECK_OK.txt`" ]
	then
		_CACHE_PKG="`sed -n ${LINE_MAX}p ~/CACHE_CHECK_OK.txt | awk -F '.tgz' '{print $1}'`"
		_PKG_INSTALLED="`cat ~/PKG_INSTALLED_LIST.txt | grep "$_CACHE_PKG"`"
		clear
		echo "${LINE_MAX} ${_CACHE_PKG}"
		if [ -z "$_PKG_INSTALLED" ]
		then
			ln ${_CACHE_PKG}.tgz ~/PKG_NEED_INSTALL/${_CACHE_PKG}.tgz
		fi
	fi
	LINE_MAX=$(($LINE_MAX-1))
done

cd ~/PKG_NEED_INSTALL
ls *.tgz | sort >> PKG_NEED_INSTALL.TXT
LINE_MAX=`sed -n $= PKG_NEED_INSTALL.TXT`
LINE_MAX=$(($LINE_MAX+0))
while  [ $LINE_MAX -ge 1 ]
do
	if [ -n "`sed -n ${LINE_MAX}p PKG_NEED_INSTALL.TXT`" ]
	then
		clear
		echo "${LINE_MAX} :"
		doas pkg_add "`sed -n ${LINE_MAX}p PKG_NEED_INSTALL.TXT`" 2>> ~/UPDATE_CACHE_ERROR_LOG.txt
	fi
LINE_MAX=$(($LINE_MAX-1))
done
rm -rf ~/PKG_NEED_INSTALL/*

if [ -n "`cat ~/UPDATE_CACHE_ERROR_LOG.txt 2> /dev/null`" ]
then
	echo "\n### may be you need to run this programe again. ###\n" >> ~/UPDATE_CACHE_ERROR_LOG.txt
	cat ~/UPDATE_CACHE_ERROR_LOG.txt | more
fi
cd "$WK_DIR"

