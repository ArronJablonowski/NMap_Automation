#!/bin/bash
# This script will run NMap 
# example: ./enum_services_ByIP.sh <path/to/file>
# example: ./enum_services_ByIP.sh ./targetList.txt
# Author: Arron Jablonowski 
# Last Updated: 2024.10.22 

#Path to Target List 
targetList=$1
#Path to Results Folder 
resultsDir="./results"

#If folder does not exist 
if [ ! -d "$resultsDir" ]; then mkdir $resultsDir; fi

while IFS= read -r line
do	
    echo ""
    echo "Enumerating Services on: $line"
    echo "---------------------------------------------"
    if [ -f "$resultsDir/$line-nmap.txt" ]; then 
        echo " - File exists. Skipping. "
    else 
        # Run NMap	   
        # nmap -A -Pn $line --reason | tee ./results/$line-nmap.txt	
        # nmap -A -Pn $line --open > $resultsDir/$line-nmap.txt	
        nmap -A -p- $line --open > $resultsDir/$line-nmap.txt	

        # nmap -sS -sV -p 20,21,22,23,25,53,80,137,139,143,179,264,443,445,587,993,1010,2020,2022,5001,5060,8080,8088,8089,8443,8022,8445,9000,4001,18264 $line --open > $resultsDir/$line-nmap.txt	

        sleep 1
        grep -R 'open' $resultsDir/$line-nmap.txt
    fi 

done <"$targetList"
