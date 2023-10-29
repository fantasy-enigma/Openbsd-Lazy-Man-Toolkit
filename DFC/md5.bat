#! /bin/sh

cat ~/temp/SSlist.txt | awk -F '^ {0,}[0-9]{0,} ' '{printf $2"\n"}' > ~/temp/list.txt

while [ `sed -n '$=' ~/temp/list.txt` -gt 0 ]
do
	count=`sed -n '$=' ~/temp/list.txt`
	echo "remaining $count file need md5 check."

	Fname="`head -1 ~/temp/list.txt`"
	md5 "$Fname" >> ~/temp/md5list.txt
	sed -i 1d ~/temp/list.txt
done
