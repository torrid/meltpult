#!/bin/bash


VDEV=$(v4l2-ctl --list-devices -k | grep -A 3 HD-5000 | grep /dev/video  | head -n1)
FR=20
SH=38

echo $VDEV | grep -q /dev/video || exit
v4l2-ctl -d $VDEV -c focus_automatic_continuous=0
sleep 1
v4l2-ctl -d $VDEV -c focus_automatic_continuous=0,focus_absolute=$SH
v4l2-ctl -d $VDEV -c brightness=150,white_balance_automatic=0,white_balance_temperature=2500,brightness=150,contrast=5,focus_automatic_continuous=0,focus_absolute=$SH
OUTFILE="Out/$(/bin/date +"%Y-%m-%d-%H-%M-%S")-$RANDOM.mp4"
mkdir -p Out

FONT=/usr/share/fonts/adobe-source-code-pro/SourceCodePro-Medium.otf
BESTIES=" -c:v libx264 -preset fast -crf 22 -tune grain -tune zerolatency "

mkfifo /tmp/mpegpipe 
ffmpeg -loglevel error -stats -hide_banner -f v4l2 -framerate $FR    \
	-video_size 1280x720 -input_format mjpeg                     \
	 -i $VDEV -f tee -map 0 $BESTIES                             \
         -vf "drawtext=fontfile=$FONT:fontsize=38:box=1:boxcolor=green@1.0:text='Time\: %{pts\:gmtime\:0\:%M\\\\\:%S}s'"         \
	 "$OUTFILE|[f=nut]pipe:" > /tmp/mpegpipe & 
	
FF=$!
ffplay /tmp/mpegpipe
kill $FF

echo 
echo "########################################"
echo "#                                      #"
echo "#  $(printf "%20s" $OUTFILE)   #"
echo "#                                      #"
echo "########################################"

