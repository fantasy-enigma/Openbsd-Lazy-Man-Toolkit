#! /bin/sh

FLAG_CURRENT=$1

clear
rm -rf ~/.ssh/*
cat /home/CVS/CVSroot.txt
CVSROOT=`cat /home/CVS/CVSroot.txt | grep "CVSROOT=" | awk -F '=' '{printf $2}'`
OS_VERSION="OPENBSD_`sysctl | grep 'kern\.osrelease\=' | awk -F '=' '{print $2}' | sed s/'\.'/_/g`"
# OS_VERSION=`cat OS_VERSION.TXT`

cd /usr
if [ "$FLAG_CURRENT" = "current" ]
then
	echo "## checkoutCVS begin: `date`"
	echo "## checkoutCVS begin: `date`" >> /home/CVS/autoCVS.log
	cvs -qd $CVSROOT checkout -P src >> /home/CVS/autoCVS.log 2>> /home/CVS/autoCVS.log
	cvs -qd $CVSROOT checkout -P xenocara >> /home/CVS/autoCVS.log 2>> /home/CVS/autoCVS.log
#	cvs -qd $CVSROOT checkout -P ports >> /home/CVS/autoCVS.log 2>> /home/CVS/autoCVS.log
	echo "## checkoutCVS finish: `date`\n\n" >> /home/CVS/autoCVS.log
	echo "## checkoutCVS finish: `date`"
else
	echo "## checkoutCVS begin: `date`"
	echo "## checkoutCVS begin: `date`" >> /home/CVS/autoCVS.log
	cvs -qd $CVSROOT checkout -r$OS_VERSION -P src >> /home/CVS/autoCVS.log 2>> /home/CVS/autoCVS.log
	cvs -qd $CVSROOT checkout -r$OS_VERSION -P xenocara >> /home/CVS/autoCVS.log 2>> /home/CVS/autoCVS.log
#	cvs -qd $CVSROOT checkout -r$OS_VERSION -P ports >> /home/CVS/autoCVS.log 2>> /home/CVS/autoCVS.log
	echo "## checkoutCVS finish: `date`\n\n" >> /home/CVS/autoCVS.log
	echo "## checkoutCVS finish: `date`"
fi

  rsync -av /usr/src/ /home/CVS/src
  rsync -av /usr/xenocara/ /home/CVS/xenocara
# rsync -av /usr/ports/ /home/CVS/ports
