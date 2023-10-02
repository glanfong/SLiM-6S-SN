#!/bin/bash
# Create the directory if it doesn't exist
mkdir -p noCounterpart_MS

# To extract id of sim for which .ms files were not generated :
# ls | grep .ms | cut -d_ -f1 | cut -d- -f4 | uniq -c | cut -d' ' -f7,8 | grep '1 '

# Generate a list of IDs with only one occurrence
ids=$(ls | grep .ms | cut -d_ -f1 | uniq -c | cut -d' ' -f7,8 | grep '1 ' | cut -d' ' -f2)

# Iterate through the IDs and move corresponding files to noCounterpart_MS
for id in $ids; do
    # Move files with the corresponding ID to the noCounterpart_ms directory
    mv *"${id}"* noCounterpart_MS/
done
