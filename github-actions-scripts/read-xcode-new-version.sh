#!/bin/bash
filename="newest_xcode.txt"
while read -r line; do
    name="$line"
done < "$filename"
echo $name