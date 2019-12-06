#!/bin/bash
#####################################
#
# Author: Jeremy Webb
# Version: v1.0.0
# Date: 2019-11-24
# Description: Determines file sizes on disk
# Usage: ./findFileSizes.sh
#
#####################################
touch /scripts/logs/findFileSizes.log
logLocation=/scripts/logs/findFileSizes.log

exec > >(tee -a $logLocation) 2>&1

sendEmail() {
  echo "$(date +"%m-%d-%y") $(date +"%r")
      "$1"" | mail -s "Information on script: ${0##*/}" oracle
}

findMountSize() {
  #Excludes strings with filesystem, shm and boot. Used to ignore mainly untouched directories
  #Uses AWK to print 5th & 6th column, in this case our use% column and directory
  #-E allows special characters, -v means to find any line NOT containing something
  #Grabs filesystems that are greater than 80% full based on df, use% column

  systemLocations=(`df -m | grep -vE "^Filesystem|shm|boot" |  awk '{ print +$5 $6 }'`)

  for var in "${systemLocations[@]}"
  do
    #Use parameter expansion to separate string based on character '/'
    directoryLoc=${var#*/}
    if [[ $var > 80 ]]; then
      echo " "
      echo "------------------"
      echo "------------------"
      echo "Performing filesystem checks for large files..."
      echo "Found usage higher than 80% in /$directoryLoc. Locating >100MB files.."
      echo "Printing and mailing results to local mail server.."
      echo "------------------"
      echo "------------------"
      echo " "
      #Finds files larger than 100mb and sorts it based on largest to smallest.
      sudo find /$directoryLoc/ -xdev -type f -size +100M -exec du -sh {} ';' | sort -rh | head -n50
      #Saves the results into a variable, then e-mails that to the local Oracle account
      fileResult="$(sudo find /$directoryLoc/ -xdev -type f -size +100M -exec du -sh {} ';' | sort -rh | head -n50)"
      sendEmail "$fileResult"
    else
      #Using here-strings, awk processes $var for all characters before the first "/".
      echo "/$directoryLoc currently lower than 80%, so no additional checks required. Current percentage used: $(awk -F/ '{print $1}' <<< "$var")"
    fi
  done

}

findMountSize
