#!/bin/bash
	
#echo "$1"
#echo "$2"
#echo "$#"

no_of_matched_files=0

working_dir="working_dir"
default_dir="true"

if [ $# -eq 0 ]; then
	 echo "No command line argument,please give at least one argument"
	 exit          

elif [ $# -eq 2 ]; then
	default_dir="false"
	working_dir="$1"
         if [ -f "$2" ]; then 
		input_file=$2
	#	echo "paise"
         else 
			
	         echo  "File is not valid,give a valid file name:"
				exit
					 	 		 
         fi	

elif [ $# -eq 1 ]; then 
    if [ -f "$1" ]; then 
		input_file=$1
	       # echo "paise"	
    else 
	
		  echo  "File is not valid,give a valid file name:"
		   exit
    fi	
	
else 
	echo "Invalid number of arguments"
	exit

fi

n=1

while read line; 
 do
   if [ $n -eq 1 ]; then
	searching_portion=$line
   fi
	
   if [ $n -eq 2 ]; then
	searching_line=$line
   fi	
   
   if [ $n -eq 3 ]; then
	searching_string=$line
   fi
	 

n=$((n+1))
	 
done <"$input_file"



output_dir="output_dir"
csv_file="output.csv"
rm -r "$output_dir"
mkdir  "$output_dir"

rm -r "$csv_file"


touch "$csv_file"

echo "File path  ,   Line No  ,  Matched line" >>"$csv_file"








function traverse() {
for f in "$1"/*
do
    if [  -d "${f}" ] ; then
        
        traverse "${f}"
    else
     
	
	            if  [ "$searching_portion" = "begin" ]; then
					  
						line_no=$(head -n "$searching_line" "$f"|grep -n -i -m1 "$searching_string"|cut -d ":" -f1)

       					matched_line=$(head -n "$searching_line" "$f"|grep  -i -m1 -h "$searching_string")
					


						if [ -n "$line_no" ]; then
								


								no_of_matched_files=$((no_of_matched_files+1))
							
							
								file_extension="$(echo ${f} | cut -d '.' -f2)"
						
								    	
 
	        					modified_filename="$(echo ${f} | cut -d '.' -f1 | sed -e 's/\//./g' -e 's/ //g')"

								modified_filename_2=$(echo "$modified_filename" | cut -d '.' -f1)

							

								if [ "$modified_filename_2" = "" ];then
										modified_filename=$(echo $modified_filename | sed 's/.//')
								fi		



	        					
								if [ "$f" = "$file_extension" ]; then
								  
								   newfilename="$output_dir/${modified_filename}_${line_no}"
	        					   

								else  
								   newfilename="$output_dir/${modified_filename}_${line_no}.${file_extension}"
								fi   

 
			        			touch $newfilename
	    		    			cp "$f" "$newfilename"

								lines_no=$(head -n "$searching_line" "$f"|grep -n -i  "$searching_string"|cut -d ":" -f1)


								matched_lines=$(head -n "$searching_line" "$f"|grep -n  -i  -h "$searching_string")
							


								while IFS= read -r line
								do
   									x=$(echo "$line"|cut -d ":" -f1)
									y=$(echo "$line"|cut -d ":" -f2)   
								    echo "${f},${x},${y}" >> "$csv_file"
									
								done < <(printf '%s\n' "$matched_lines")


							

						fi		  



				else 
#         				
				      line_no=$(tail -n  "$searching_line" "$f"|grep -n -i "$searching_string"|tail -1|cut -d ":" -f1)

       			     matched_line=$(tail -n  "$searching_line" "$f"|grep  -i  -h "$searching_string"|tail -1)

				    total_file_line=$(wc -l < "$f")

					if [ "$searching_line" -gt "$total_file_line"  ]; then
									final_line_no=$line_no
					else 
								   final_line_no=$((total_file_line-searching_line+line_no))
				
					fi				

                

				     	if [ -n "$line_no" ]; then
						        
							#	echo "${f} , ${final_line_no} , ${matched_line}" >>"$csv_file" 
								no_of_matched_files=$((no_of_matched_files+1))
							
									file_extension="$(echo ${f} | cut -d '.' -f2)"
									
							
 
	        					modified_filename="$(echo ${f} | cut -d '.' -f1 | sed -e 's/\//./g' -e 's/ //g')"

								modified_filename_2=$(echo "$modified_filename"|cut -d "." -f1)
								if [ "$modified_filename_2" = "" ];then
										modified_filename=$(echo "$modified_filename" | sed 's/.//')
								fi	
							

								

								if [ "$f" = "$file_extension" ]; then
								  
								   newfilename="$output_dir/${modified_filename}_${final_line_no}"
	        					   

								else  
								   newfilename="$output_dir/${modified_filename}_${final_line_no}.${file_extension}"
								fi   


			        			touch $newfilename
	    		    			cp "$f" "$newfilename"	


 								matched_lines=$(tail -n  "$searching_line" "$f"|grep -n -i  -h "$searching_string")
							#	matched_lines=$(head -n "$searching_line" "$f"|grep -n  -i  -h "$searching_string")
							



								while IFS= read -r line
								do
									x=$(echo "$line"|cut -d ":" -f1)	
									if [ "$searching_line" -gt "$total_file_line"  ]; then
									      x=$x
								    else 
								         x=$((total_file_line-searching_line+x))
									fi		
   									
									y=$(echo "$line"|cut -d ":" -f2)   
								    echo "${f},${x},${y}" >> "$csv_file"
									
								done < <(printf '%s\n' "$matched_lines")




						fi
				fi
   	
    fi


done
}

traverse "$working_dir"
echo "No of  files meeting the criteria= $no_of_matched_files "








