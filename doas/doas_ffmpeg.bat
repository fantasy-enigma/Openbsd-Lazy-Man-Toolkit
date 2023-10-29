#! /bin/sh

URL_BROADCAST="`head -n 1 ~/Desktop/url_broadcast.txt`"
KEY_BROADCAST="`head -n 1 ~/Desktop/key_broadcast.txt`"

/home/BAT/doas/guard_ffmpeg.bat &

doas sysctl kern.audio.record=1
doas rcctl set sndiod flags -s default -m play,mon -s mon
doas rcctl restart sndiod

doas -u caven /home/BAT/doas/ffmpeg.bat "${URL_BROADCAST}${KEY_BROADCAST}"

doas sysctl kern.audio.record=0
doas rcctl set sndiod flags
doas rcctl restart sndiod

