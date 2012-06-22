#!/bin/sh

echo "Coming in"

# Pass the base dir. Quote it if it has spaces. Mandatory that the directory is truncated with trailing '/'.
base_dir=$1
# The complete path to the output file (including the file name). Quoted if path has spaces.
output_file_name=$2
# Pass true or false value. If true it is recursive find, anything else it is 
recursive=$3
# Pass the file filters that are accepted as part of egrep. To find files that end with a certain extension use the following sample:
# "\.mov$|\.mp4$|\.m4v$|\.mp3$"
# This argument has to be passed unquoted mandatorily.
file_filters=$4

# Echo values:
echo "base_dir = $base_dir"
echo "output_file_name = $output_file_name"
echo "recursive = $recursive"
echo "file_filters = $file_filters"

# TODO: Handle the issues of folder access here and exit the script with error (to avoid infinite loop)
rm -f "$output_file_name"
touch "$output_file_name"

if [ "$recursive" == "true" ]
then
	echo "Will recurse and find files that match the filters."
	echo "Will issue command -> find "$base_dir" | egrep -i "$file_filters" >> "$output_file_name""
    
    find "$base_dir" | egrep -i $file_filters >> "$output_file_name"

else
	echo "Will not recurse but find files in the given base directory that match the filters."
	echo "Will issue command -> ls -d "$base_dir"* | egrep -i "$file_filters" >> "$output_file_name""

    ls -d "$base_dir"* | egrep -i $file_filters >> "$output_file_name"

fi
# Exit with 0 always. This guarantees if no results are found.
exit 0