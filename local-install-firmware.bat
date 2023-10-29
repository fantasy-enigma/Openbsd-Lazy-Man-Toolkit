#! /bin/sh

ls *firmware*.tgz > firmware-list.txt

while [ `head -n 1 firmware-list.txt` ]
do
	head -n 1  firmware-list.txt > firmware-name.txt
	cat firmware-name.txt | awk -F '.tgz' '{print $1}' > firmware-direct.txt
	cat firmware-direct.txt | xargs -n 1 -J % mkdir %
	firmware_dir=`cat firmware-direct.txt`
	cat firmware-name.txt | xargs -n 1 -J % tar -pxzf % -C $firmware_dir
	cp -af $firmware_dir/firmware /etc/
	rm -rf $firmware_dir/firmware
	chown -R root:wheel $firmware_dir
	cp -af $firmware_dir /var/db/pkg
	rm -rf $firmware_dir
	cat firmware-list.txt | grep -v `head -n 1 firmware-list.txt` > new-firmware-list.txt
	mv -f new-firmware-list.txt firmware-list.txt
done

rm -f firmware-direct.txt
rm -f firmware-list.txt
rm -f firmware-name.txt

