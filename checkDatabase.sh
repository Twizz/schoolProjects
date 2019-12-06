#!/bin/bash
#####################################
#
# Author: Jeremy Webb
# Version: v1.0.0
# Date: 2019-11-20
# Description: Determines database accessibility
# Usage: ./checkDatabase.sh
#
# Purpose:
# First executes our script in a new process, redirecting output to our log.
# Labels our current date, then checks the system that the current user is 'oracle'.
# Then runs through essential database files to ensure they are running. If not,
# outputs error. In the case of lsnrctl, attempts to perform lsnrctl start.
# In the event of an error, sends an e-mail to the local oracle account.
#
#####################################
touch /u01/app/oracle/product/version/db_1/log/consoleLog.log
logLocation=/u01/app/oracle/product/version/db_1/log/consoleLog.log

#Records results of entire script by executing script in new process
exec > >(tee -a $logLocation) 2>&1
oracleSid=$ORACLE_SID

echo " "
echo "-------------------------------"
echo $(date +"%m-%d-%y") $(date +"%r")
echo "-------------------------------"


sendEmail() {
  echo "$(date +"%m-%d-%y") $(date +"%r")
      "$1"" | mail -s "Error on script: ${0##*/}" oracle
}

#Function to check our processes
#Essential processes as shown here:
#https://docs.oracle.com/database/121/CNCPT/process.htm#CNCPT9840
#pmon, smon, dbw, lgwr, ckpt, reco, mmon, mmnl, and lreg.

checkProcesses() {
  checkProcessArray=( "tnslsnr" "pmon" "smon" "dbw" "lgwr" "ckpt" "reco" "mmon" "mmnl" )
  for p in "${checkProcessArray[@]}"; do
      if pgrep "$p" > /dev/null; then
          echo "Process '$p' is running"
      else
        if [[ "$p" == "tnslsnr" ]]; then
          echo "Listener not started -- attempting to restart listener.."
          lsnrctl start
          continue
        fi

        echo "Process '$p' is not running. As it is an essential process, this script will abort. Please restart the database."

        sendEmail "Process '$p' is not running. As it is an essential process, this script will abort. Please restart the database.
        Script exiting.."

        exit
      fi
  done
}

#Function to check our system
checkSystem() {
  echo "Checking user.."
  if [[ "$USER" != "oracle" ]]; then
    echo "Not currently logged in as Oracle. Please login as Oracle to run this script."
    exit
  else
    echo "Logged in as oracle."
  fi
  echo "Checking processes.."

  checkProcesses

  echo "Checking ORACLE_SID.."
  if [[ $oracleSid != orclcdb ]]; then

    if [[ -z $oracleSid ]]; then
      echo "$(date +"%m-%d-%y") $(date +"%r")
      ORACLE_SID string is empty." | mail -s "Error" oracle
    else
      echo "$(date +"%m-%d-%y") $(date +"%r")
      ORACLE_SID does not match 'orclcdb'." | mail -s "ORACLE_SID not matching" oracle
    fi

  else

    echo "ORACLE_SID is $oracleSid"

  fi

}

checkSystem
