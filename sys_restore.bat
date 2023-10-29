#! /bin/sh

HASH_STRING="$1"
HASH_STR_SIZE=`echo "$HASH_STRING" | awk '{print length($1)}'`
BACKUP_FILES_DIR="/mnt2/backup"

if [ -n "`mount | grep /dev/sd0a`" ]
then
	echo "Warning : /dev/sd0a has mounted ,if you are run system on this partion , don't execult sys_store.bat, if not please umount it and try again."
	exit
fi

if [ -n "`mount | grep /dev/sd0d`" ]
then
	echo "Warning : /dev/sd0d has mounted ,if you are run system on this partion , don't execult sys_store.bat, if not please umount it and try again."
	exit
fi

if [ -d "$BACKUP_FILES_DIR" ]
then
	if [ $HASH_STR_SIZE -lt 12 ]
	then
		echo "hash size must be > 11 "
		exit
	else
		BACKUP_FILE_PATH="`ls ${BACKUP_FILES_DIR}/* | xargs -n 1 -J % sha256 % | grep "$HASH_STRING" | sed -n 1p | awk -F '(' '{print $2}' | awk -F ')' '{print $1}'`"
	fi
else
	echo "can't find backup direct"
	exit
fi

if [ -n "$BACKUP_FILE_PATH" ]
then
	newfs -o time sd0a
	newfs -o time sd0d
	mount -o noatime,softdep /dev/sd0a /mnt
	mkdir /mnt/var
	mount -o noatime,softdep /dev/sd0d /mnt/var
	cd /mnt
	cpio -idmuzF ${BACKUP_FILE_PATH} -H sv4cpio
	sync
	fdisk -yu sd0
	cd /mnt/usr/mdec
	installboot -vr /mnt sd0 biosboot boot
	sync	
else
	echo "can't find backup file match hash! \n"
fi
