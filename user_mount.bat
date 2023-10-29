#! /bin/sh

doas /home/BAT/ro_ntfs.bat
/usr/local/bin/thunar /mnt/ntfs
notify-send "`mount`"

