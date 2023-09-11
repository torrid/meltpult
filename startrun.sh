#!/bin/bash


VDEV=$(v4l2-ctl --list-devices -k | grep -A 3 HD-5000 | grep /dev/video  | head -n1)
FR=20

echo $VDEV | grep -q /dev/video || exit
v4l2-ctl -d $VDEV -c focus_automatic_continuous=0
sleep 1
v4l2-ctl -d $VDEV -c focus_automatic_continuous=0,focus_absolute=37
OUTFILE="Out/$(/bin/date +"%Y-%m-%d-%H-%M-%S")-$RANDOM.mp4"

FONT=/usr/share/fonts/adobe-source-code-pro/SourceCodePro-Medium.otf
# OVERLAY="\"drawtext=fontfile=$FONT:fontsize=38:box=1:boxcolor=white@0.5:text='Time\: %{pts\:gmtime\:0\:%M\\\\\:%S}s'\""
BESTIES=" -c:v libx264 -preset fast -crf 22 "

mkfifo /tmp/mpegpipe 
ffmpeg -f v4l2 -framerate $FR                               \
	-video_size 1280x720 -input_format mjpeg            \
	 -i $VDEV -f tee -map 0 $BESTIES                    \
         -vf "drawtext=fontfile=$FONT:fontsize=38:box=1:boxcolor=white@0.5:text='Time\: %{pts\:gmtime\:0\:%M\\\\\:%S}s'"         \
	 "$OUTFILE|[f=nut]pipe:" > /tmp/mpegpipe & 
	
FF=$!
ffplay /tmp/mpegpipe
kill $FF
