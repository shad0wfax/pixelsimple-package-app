#!/bin/sh

# Params:
# directory to monitor.
# Playlist file (or should this create it?)
# Pattern of file getting written (ex: *.ts)
# Time to check the directory repeatedly.
# Transcode complete file to be checked, in order to assume transcoding is complete.
# The time of each segment.
# Ffprobe path to determine each segment time once transcode is complete.
# Base URI (ex: nova/hls?fileName=)
# 

# 
hls_media_dir=$1
playlist_file=$2
hls_file_extension_pattern="\."$3"$"
check_interval_in_sec=$4
hls_transcode_complete_file=$5
segment_time=$6
ffprobe_path=$7
base_uri=$8
temp_playlist_file="$hls_media_dir""temp.m3u8"
log_file="$hls_media_dir""hls_log.txt"
hls_file_start="#EXTM3U"
hls_file_duration="#EXT-X-TARGETDURATION:"
hls_file_sequence="#EXT-X-MEDIA-SEQUENCE:0"
hls_segment_header="#EXTINF:"
hls_file_end="#EXT-X-ENDLIST"

# TODO: Handle the issues of folder access here and exit the script with error (to avoid infinite loop)
rm -f "$playlist_file"
rm -f "$temp_playlist_file"
rm -f "$log_file"

touch "$playlist_file"
touch "$temp_playlist_file"
touch "$log_file"

# target_duration is hard coded to segment_time for now. Can extend this to be a param if needed.
hls_file_duration=$hls_file_duration$segment_time

# Echo stuff to log
echo "Starting hls transcoding at "  $(date) >> "$log_file"
echo "hls_media_dir = " "$hls_media_dir" >> "$log_file"
echo "playlist_file = " "$playlist_file" >> "$log_file"
echo "hls_file_extension_pattern = " "$hls_file_extension_pattern" >> "$log_file"
echo "check_interval_in_sec = " "$check_interval_in_sec" >> "$log_file"
echo "hls_transcode_complete_file = " "$hls_transcode_complete_file" >> "$log_file"
echo "segment_time = " "$segment_time" >> "$log_file"
echo "ffrobe_path = " "$ffprobe_path" >> "$log_file"
echo "base_uri = " "$base_uri" >> "$log_file"

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

        	if [ -e "$hls_transcode_complete_file" ]
            then
                # Logic to compute the actual file segment times.
                ffprobe_cmd="\"$ffprobe_path\" -i \"$hls_media_dir$file\" -print_format json -show_format 2>/dev/null | grep -i duration | cut -d : -f 2 "
                durationString=$(eval "$ffprobe_cmd")
                # compute the duration by rounding off to a number. Split the string on decimal and compare the first digigt after decimal to round off.
                durationInt=$(echo ${durationString} | cut -d . -f 1)
                # Strip the quote
                durationInt=${durationInt:1}
                durationDecimal=$(echo ${durationString} | cut -d . -f 2)
                # Get the first digit after decimal
                durationDecimal=${durationDecimal:0:1}

                if [[ $durationDecimal -ge 5 ]]
                then
                    durationInt=$(($durationInt + 1))
                fi

                echo "Duration of $file is" $durationString "but will use " $durationInt " and " $durationDecimal >> "$log_file"
                echo "$hls_segment_header"$durationInt, >> "$temp_playlist_file"
                
            else
                # If transcoding is still in progress the segment time will be kept as the default segment_time
                # Leaving segment description empty.
        		echo "$hls_segment_header"$segment_time, >> "$temp_playlist_file"
        
            fi	


		echo "$base_uri""$file" >> "$temp_playlist_file"
	done
	
	cat "$temp_playlist_file" > "$playlist_file"
}

while true
do
	if [ -e "$hls_transcode_complete_file" ]
	then
		# create one last time and then exit
		create_playlist
        # Add the file end tag
        echo "$hls_file_end" >> "$playlist_file"
        rm -f "$temp_playlist_file"
		echo "Going to exit at " $(date) >> "$log_file"
		exit 0;
	else
		create_playlist
		echo "Going to sleep at "  $(date) >> "$log_file"
		sleep $check_interval_in_sec
	fi	
done	
