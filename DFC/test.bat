#! /bin/sh

ls -sF | grep -v test.bat | grep -v / > ~/temp/list.txt

while [ `sed -n '$=' ~/temp/list.txt` -gt 0 ]
do
	head -n 1 ~/temp/list.txt > ~/temp/sample.txt
	Fsize=`cat ~/temp/sample.txt | awk -F ' ' '{print $1}'`

	sed -i 1d ~/temp/list.txt

	count=`sed -n '$=' ~/temp/list.txt`

	echo " remaining $count files need check "

	while [ `sed -n '$=' ~/temp/list.txt` -gt 0 ]
	do
		echo "file size $Fsize now find same size files"

		while [ `sed -n '$=' ~/temp/list.txt` -gt 0 ]
			do
				if [ `head -n 1 ~/temp/list.txt | awk -F ' ' '{print $1}'` = $Fsize ]
				then
					head -n 1 ~/temp/list.txt >> ~/temp/SSlist.txt
				fi

				if [ `head -n 1 ~/temp/list.txt | awk -F ' ' '{print $1}'` != $Fsize ]
				then
					head -n 1 ~/temp/list.txt >> ~/temp/NOmatch.txt
				fi

				sed -i 1d ~/temp/list.txt
			done
		cat ~/temp/sample.txt >> ~/temp/SSlist.txt
	done

	mv ~/temp/NOmatch.txt ~/temp/list.txt
done