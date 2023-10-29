#! /bin/sh

RAR_FILE_PATH="$1"
GWENVIWE_TEMP_DIR="/tmp/GWENVIWE_TEMP_DIR"
SUB_DIR_TIME="`date | sed s/' '/-/g | sed s/\:/./g`"

if [  ! -d "${GWENVIWE_TEMP_DIR}/" ]
then
	mkdir "$GWENVIWE_TEMP_DIR"
fi

notify-send "uncompress files please wait..." &

if [ -d "${GWENVIWE_TEMP_DIR}/" ]
then
	mkdir "${GWENVIWE_TEMP_DIR}/${SUB_DIR_TIME}/"
	unrar e "$RAR_FILE_PATH" "${GWENVIWE_TEMP_DIR}/${SUB_DIR_TIME}/" &
else
	echo "cant creat dir : $GWENVIWE_TEMP_DIR "
fi

gwenview "${GWENVIWE_TEMP_DIR}/${SUB_DIR_TIME}/"

rm -rf "${GWENVIWE_TEMP_DIR}/${SUB_DIR_TIME}/"

