clear
rm -rf ~/.ssh/*
cat CVSroot.txt
CVSROOT=`cat CVSroot.txt | grep "CVSROOT=" | awk -F '=' '{printf $2}'`

OS_VERSION=`cat OS_VERSION.TXT`

echo "## echo updatePORTS begin: `date`"

cd /usr
cvs -qd $CVSROOT update -r$OS_VERSION -P ports >> ~/autoCVS.log

echo "## echo updatePORTS finish: `date`"

