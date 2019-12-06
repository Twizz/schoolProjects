#!/bin/bash
timeout=10
for file in /home/oracle/scpts/CH9/*
do

    fileName=`basename "$file"`

    if [[ "$fileName" == "test.sh" ]]; then
	continue;
    fi

    #uses grep to find any arguments labeled $1 ~ $9 or starting with @, or *. -q does not output found text (quiet).

    if  grep -q '\$[1-9@*]' ${file} && grep -q '<' ${file} && grep -q '>' ${file}; then 

	echo $fileName contains arguments. Please enter as shown below:
	#-h hides the file path
	grep -h '# Usage' ${file}
	read inputParams
	echo "Working on $fileName... "
	#Timeout command will wait 10 seconds (taken from $timeout above) before stopping the current command.
	timeout $timeout $file $inputParams > /home/oracle/scpts/Output/CH9/$fileName-$(date +"%m-%d-%Y")-Jeremy.out
	echo File $fileName processed. 
	
    elif grep -q 'read' ${file}; then

	echo "Working on $fileName... "
	$file > /home/oracle/scpts/Output/CH9/$fileName-$(date +"%m-%d-%Y")-Jeremy.out
	echo File $fileName processed.

    else
 
        echo "Working on $fileName... "
	timeout $timeout $file > /home/oracle/scpts/Output/CH9/$fileName-$(date +"%m-%d-%Y")-Jeremy.out
	echo File $fileName processed.

    fi

done