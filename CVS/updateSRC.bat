clear
rm -rf ~/.ssh/*
cat CVSroot.txt
CVSROOT=`cat CVSroot.txt | grep "CVSROOT=" | awk -F '=' '{printf $2}'`

OS_VERSION=`cat OS_VERSION.TXT`

echo "## updateSRC begin: `date`"
echo "## updateSRC begin: `date`" >> ~/autoCVS.log

cd /usr
cvs -qd $CVSROOT update -r$OS_VERSION -P src >> ~/autoCVS.log

cd /usr
cvs -qd $CVSROOT update -r$OS_VERSION -P xenocara >> ~/autoCVS.log

echo "## updateSRC finish: `date`"
echo "## updateSRC finish: `date`" >> ~/autoCVS.log

