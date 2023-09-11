#!/bin/bash

VDEV=$(v4l2-ctl --list-devices -k | grep -A 3 HD-5000 | grep /dev/video  | head -n1)
echo $VDEV | grep -q /dev/video || exit

v4l2-ctl -d $VDEV -c focus_automatic_continuous=0
sleep 1
v4l2-ctl -d $VDEV -c focus_automatic_continuous=0,focus_absolute=37
OUTFILE="$(/bin/date +"%Y-%m-%d-%H-%M-%S")-$RANDOM.mp4"

# OVERLAY=" -vf \"drawtext=fontfile=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans-Bold.ttf: text='\%T': fontcolor=white@0.8: x=7: y=460\""
OVERLAY=""
BESTIES=" -c:v libx264 -preset slow -crf 22 "

ffmpeg -f v4l2 -framerate 25                                \
	-video_size 1280x720 -input_format mjpeg            \
         $OVERLAY \
	 -i $VDEV -f tee -map 0 $BESTIES "$OUTFILE|[f=nut]pipe:" | ffplay pipe: 

