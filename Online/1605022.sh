#!/bin/bash

friends_file="$1"
places_file="$2"
visited="$3"
out="visitor_count.txt"

rm -r "$out"

touch $out

places_count=$(wc -l "$places_file")
friends_count=$(wc -l "$friends_file")

least_visited_count=10000

while read line; 
 do
   place="$line"
   
        x=$(grep -o "$place" "$visited" | wc -l)
        if [ "$x" -lt "$least_visited_count" ]; then
		least_visited_count="$x"
		least_visited_place="$place"
	fi		
	echo -e "$place" >> "$out"
	echo "$x" >> "$out"
        

	 
done <"$places_file"


echo "The least visited place is $least_visited_place " >> "$out"







