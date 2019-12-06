#!/bin/bash
#####################################
#
# Author: Jeremy Webb
# Version: v1.0.0
# Date: 2019-11-24
# Description: Determines mountpoint sizes on disk
# Usage: ./findLargeMountPoints.sh
#
#####################################
touch /scripts/logs/findLargeMountPoints.log
logLocation=/scripts/logs/findLargeMountPoints.log

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
  echo "Performing filesystem checks for large mount points..."

  for var in "${systemLocations[@]}"
  do
    directoryLoc=${var#*/}
    if [[ $var < 40 ]]; then


      #Using here-strings, awk processes $var for all characters before the first "/".
      echo "Mount point: /$directoryLoc. Current usage: $(awk -F/ '{print $1}' <<< "$var")%"
    else
      echo "Mount point: /$directoryLoc taking a lot of space. Current usage: $(awk -F/ '{print $1}' <<< "$var")%"
      sendEmail "Mount point: /$directoryLoc taking a lot of space. Current usage: $(awk -F/ '{print $1}' <<< "$var")%"
    fi

  done

  echo "Printing and mailing results to local mail server.."

}

findMountSize
