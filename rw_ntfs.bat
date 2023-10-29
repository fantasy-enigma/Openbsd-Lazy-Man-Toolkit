#! /bin/sh

if [ -n "`ps | grep ro_ntfs.bat | grep -v grep`" ]
then
	exit
fi

uname=apple:
gname=_p2p_share:
uid=`grep -Re ^$uname /etc/passwd | awk -F ':' '{print $4}'`
gid=`grep -Re ^$gname /etc/group | awk -F ':' '{print $4}'`
## convert string to integer
uid=` expr $uid + 0 `
gid=` expr $gid + 0 `

mount_stat=`mount | grep "/mnt/ntfs"`

if [ -z "$mount_stat" -a $uid -ge 1000 -a $gid -ge 1000 ]
then
	ntfs-3g -o rw,uid=$uid,gid=$gid,fmask=137,dmask=027,locale=zh_CN.UTF-8,nodev,nosuid,noatime,max_read=131072,streams_interface=windows,windows_names,big_writes /dev/sd1i /mnt/ntfs
fi

