#! /bin/sh

FLAG_KEEP_KEY="$1"

doas sysctl kern.audio.record=1
doas rcctl set sndiod flags -s default -m play,mon -s mon
doas rcctl restart sndiod

URL_BROADCAST="`head -n 1 ~/Desktop/url_broadcast.txt`"
KEY_BROADCAST="`head -n 1 ~/Desktop/key_broadcast.txt`"

if [ "${FLAG_KEEP_KEY}" = "keepkey" ]
then
	echo "warring: you chose to keep stream key in  ~/Desktop/key_broadcast.txt"
else
	echo "default clear stream key !" > ~/Desktop/key_broadcast.txt
fi

ffmpeg -re -rtbufsize 1500M \
-f sndio -thread_queue_size 5120 -i snd/mon \
-f x11grab -thread_queue_size 5120 -framerate 24 -r 24 -i :0.0 \
-vcodec libx264 -r 24 -pix_fmt yuv420p -preset medium -profile:v high -bufsize 1500m -bit_rate 1500k \
-acodec aac -ar 48000 -ac 2 -async 20 -bufsize 150m -bit_rate 256k \
-f flv "${URL_BROADCAST}${KEY_BROADCAST}" \
1>/dev/null

doas sysctl kern.audio.record=0
doas rcctl set sndiod flags
doas rcctl restart sndiod

