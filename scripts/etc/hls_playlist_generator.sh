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
hls_media_dir=$1
playlist_file=$2
hls_file_extension_pattern="\."$3"$"
check_interval_in_sec=$4
hls_transcode_complete_file=$5
segment_time=$6
base_uri=$7
temp_playlist_file="$hls_media_dir""temp.m3u8"
log_file="$hls_media_dir""hls_log.txt"
hls_file_start="#EXTM3U"
hls_file_duration="#EXT-X-TARGETDURATION:"
hls_file_sequence="#EXT-X-MEDIA-SEQUENCE:0"
# TODO: what is that 10 below? read the damn manual!
hls_segment_header="#EXTINF:10, no desc"
hls_file_end="#EXT-X-ENDLIST"

# TODO: Handle the issues of folder access here and exit the script with error (to avoid infinite loop)
rm -f "$playlist_file"
rm -f "$temp_playlist_file"
rm -f "$log_file"

touch "$playlist_file"
touch "$temp_playlist_file"
touch "$log_file"

hls_file_duration=$hls_file_duration$segment_time

# Echo stuff to log
echo "Starting hls transcoding at "  $(date) >> "$log_file"
echo "$hls_media_dir" >> "$log_file"
echo "$playlist_file" >> "$log_file"
echo "$hls_file_extension_pattern" >> "$log_file"
echo "$check_interval_in_sec" >> "$log_file"
echo "$hls_transcode_complete_file" >> "$log_file"
echo "$segment_time" >> "$log_file"
echo "$base_uri" >> "$log_file"

create_playlist(){

	# empty file first
	cat /dev/null > "$temp_playlist_file"
	# create the file hearder parts
	echo "$hls_file_start" >> "$temp_playlist_file"
	echo "$hls_file_duration" >> "$temp_playlist_file"
	echo "$hls_file_sequence" >> "$temp_playlist_file"

#	for file in `ls "$hls_media_dir" | grep "$hls_file_extension_pattern" ` ; 
	ls "$hls_media_dir" | grep "$hls_file_extension_pattern" | while read file;
	do
		echo "$hls_segment_header" >> "$temp_playlist_file"
		echo "$base_uri$hls_media_dir""$file" >> "$temp_playlist_file"
	done
	
	echo "$hls_file_end" >> "$temp_playlist_file"
	cat "$temp_playlist_file" > "$playlist_file"
}

while true
do
	if [ -e "$hls_transcode_complete_file" ]
	then
		# create one last time and then exit
		create_playlist
		rm -f "$temp_playlist_file"
		echo "Going to exit at " $(date) >> "$log_file"
		exit 0;
	else
		create_playlist
		echo "Going to sleep at "  $(date) >> "$log_file"
		sleep $check_interval_in_sec
	fi	
done	