#!/bin/sh

# Params:
# directory to monitor.
# Playlist file (or should this create it?)
# Time to check the directory repeatedly. (Default to time of each segment or sooner?)
# Base URI (ex: nova/hls?fileName=)
# Pattern of file getting written (follow ffmpeg pattern?)
# Bit rate (validate why we need this)
# The time of each segment.
# Number of files - (Optional? in case of live feed)
# 

# Logic:
# Set TIME=0;
# START: Read the given directory in a loop every Ts (Where T = timxe to check directory repeatedly)
#  - Look for a file of the pattern supplied that has been written 
#  - 
# 
# 
# 
# 
# END
# 



#CMD=touch
#FILE=~/Downloads/transcoded/yeshir_yeli.txt

# how exactly to iterate over a directory to go over and check the set of files that get written. 

#exec "$CMD" $FILE

hls_media_dir=$1
playlist_file=$2
hls_file_extension_pattern="*."$3
base_uri=$4
check_interval_in_sec=$5
unique_process_identifier=$6
segment_time=$7
ffmpeg_hls_pattern="ffmpeg -y .*$unique_process_identifier"
temp_file="temp.m3u8"
log_file="log.txt"
hls_file_start="#EXTM3U"
hls_file_duration="#EXT-X-TARGETDURATION:"
hls_file_sequence="#EXT-X-MEDIA-SEQUENCE:0"
# TODO: what is that 10 below? read the damn manual!
hls_segment_header="#EXTINF:10, no desc"
hls_file_end="#EXT-X-ENDLIST"

cd $hls_media_dir

rm -f $playlist_file
rm -f $temp_file

touch $playlist_file
touch $temp_file
touch $log_file

if [ -z "$check_interval_in_sec" ]
then
	echo "no check_interval_in_sec supplied, setting to default 10s"  >> $log_file
	# default 10s
	check_interval_in_sec=10
fi

if [ -z "$segment_time" ]
then
	echo "no segment_time is supplied, setting to default 10s"  >> $log_file
	# default 10s
	segment_time=10
fi
hls_file_duration=$hls_file_duration$segment_time

create_playlist(){

	# empty file first
	cat /dev/null > $temp_file
	# create the file hearder parts
	echo "$hls_file_start" >> $temp_file
	echo "$hls_file_duration" >> $temp_file
	echo "$hls_file_sequence" >> $temp_file

	for file in `ls $hls_file_extension_pattern` ; 
	do
		echo "$hls_segment_header" >> $temp_file
		echo "$base_uri$hls_media_dir$file" >> $temp_file
	done
	
	echo "$hls_file_end" >> $temp_file
	cat $temp_file > $playlist_file

}

# Get the pid of the process that is running the ffmpeg command for this hls transcode
ffmpeg_pid=$(ps -eo pid,args | grep -ie "$ffmpeg_hls_pattern" | grep -v grep | awk '{ print $1 }')
echo "ffmpeg_pid = $ffmpeg_pid" >> $log_file

while true
do
	process_pid=$(ps -p $ffmpeg_pid |grep "$ffmpeg_pid" | grep -v grep | awk '{ print $1 }')
	echo "process_pid = $process_pid" >> $log_file
	
	if [ -z "$process_pid" ]
	then
		# create one last time and then exit
		create_playlist
		echo "Going to exit" >> $log_file
		exit 0;
	else
		create_playlist
		echo "Going to sleep" >> $log_file
		sleep $check_interval_in_sec
	fi	
done	

rm -f $temp_file