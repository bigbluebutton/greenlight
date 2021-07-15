#!usr/bin/sh
rtmpurl=$1
disp_num=$2
ffmpeg -y -nostats -thread_queue_size 4096 -f x11grab -probesize 10M -draw_mouse 0 -framerate 30 -vsync 1 -s 1280x800 -i :$disp_num -thread_queue_size 4096 -f pulse -i default -ac 2 -c:a aac -b:a 160k -ar 48000 -threads 0 -c:v libx264 -x264-params nal-hrd=vbr -profile:v high -level:v 4.2 -vf format=yuv420p -b:v 4000k -maxrate 4000k -minrate 2000k -bufsize 8000k -g 60 -preset ultrafast -tune zerolatency -f flv -flvflags no_duration_filesize "$rtmpurl"
