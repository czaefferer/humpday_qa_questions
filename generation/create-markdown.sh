#!/bin/bash

# Source and destination directories
src_dir="raw"
dest_dir="../chapters"
topics_dir="../topics"

youtube_blank="​"

# Loop through each file in the source directory
for file in "$src_dir"/*; do
    # Check if it is a file
    if [ -f "$file" ]; then
        # Empty target file if it exists
        > "$dest_dir/$(basename "$file" | sed 's/\..*$/\.md/')"
        # Process each line in the file
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | sed "s/$youtube_blank//g")
            if [[ $line =~ ^([0-9]{1,2}):([0-9]{2}):([0-9]{2})(.*)$ ]]; then
                # Lines with hours, minutes, and seconds
                hours=${BASH_REMATCH[1]}
                minutes=${BASH_REMATCH[2]}
                seconds=${BASH_REMATCH[3]}
                rest=${BASH_REMATCH[4]}
                modified_line="[$hours:$minutes:$seconds](https://www.youtube.com/watch?v=YouTubeId&t=${hours}h${minutes}m${seconds}s)$rest  "
            elif [[ $line =~ ^([0-9]{1,2}):([0-9]{2})(.*)$ ]]; then
                # Lines with minutes and seconds
                minutes=${BASH_REMATCH[1]}
                seconds=${BASH_REMATCH[2]}
                rest=${BASH_REMATCH[3]}
                modified_line="[$minutes:$seconds](https://www.youtube.com/watch?v=YouTubeId&t=${minutes}m${seconds}s)$rest  "
            else
                # All other lines
                modified_line="$line  "
            fi

            # Append the modified line to the destination file
            echo "$modified_line" >> "$dest_dir/$(basename "$file" | sed 's/\..*$/\.md/')"
        done < "$file"
    fi
done

# Check if the key:value pairs file exists
if [ ! -f youtube_ids.txt ]; then
    echo "Error: youtube_ids.txt not found."
    exit 1
fi

# Read key:value pairs from the file and iterate over them
while IFS=':' read -r key value; do
    # Trim leading and trailing whitespaces from key and value
    key=$(echo "$key" | sed 's/^[ \t]*//;s/[ \t]*$//')
    value=$(echo "$value" | sed 's/^[ \t]*//;s/[ \t]*$//')

    # Check if the file with the given key exists in the folder
    file_path="$dest_dir/$key.md"
    if [ -f "$file_path" ]; then
        # Replace all occurrences of "YouTubeId" with the corresponding value
        sed -i "s/YouTubeId/$value/g" "$file_path"
        echo "Replaced placeholders in $file_path with $value"
    else
        echo "File not found: $file_path"
    fi
done < youtube_ids.txt

grep -irn $dest_dir -e "state manag" | awk -F'\\[' '{print substr($0,13,8)" ["$2}' | grep "https://www.youtube.com" | sort -r > $topics_dir/statemanagement.md
grep -irn $dest_dir -e "riverpod" | awk -F'\\[' '{print substr($0,13,8)" ["$2}' | grep "https://www.youtube.com" | sort -r > $topics_dir/riverpod.md
grep -irn $dest_dir -e "firebase" | awk -F'\\[' '{print substr($0,13,8)" ["$2}' | grep "https://www.youtube.com" | sort -r > $topics_dir/firebase.md
grep -irn $dest_dir -e ") live coding" | awk -F'\\[' '{print substr($0,13,8)" ["$2}' | grep "https://www.youtube.com" | grep -v ") Q" | grep -v "continued" | grep -v "cont." | sort -r > $topics_dir/live-coding.md