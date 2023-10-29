#! /bin/sh

URL_KEY="$1"
umask 007
ulimit -m 2097152
ulimit -d 2097152

while [ true ]
do
rm -f /home/caven/ffmpeg_err.txt
/usr/local/bin/ffmpeg \
-f sndio -thread_queue_size 65536 -i snd/mon \
-f x11grab -thread_queue_size 65536 -framerate 16 -discard noref -video_size 1680x1050 -i :0.0  \
-vcodec libx264 -pix_fmt yuv420p -framerate 16 -preset ultrafast -crf 39 -b:v 1500k -maxrate 4500k -bufsize:v 138149888 \
-acodec aac -ar 44100 -ac 2 -b:a 256k -bufsize:a 15718387 \
-f flv "$URL_KEY" \
2>> /home/caven/ffmpeg_err.txt
done
