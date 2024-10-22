#!/bin/bash
# This script will run NMap to create a list of targetes then check the list of targets for SSLv3 ciphers. 
# example: ./enum_ciphers_sslv3.sh <ip/cidr>
# example: ./enum_ciphers_sslv3.sh 100.100.102.0/23
# Author: Arron Jablonowski 
# Last Updated: 2024.10.22

targetList="./targetList.txt"
ResultsSSLv3="./Results_SSLv3.txt"
resultsDir="./results"

if test -z "$1";   # $1 is a positional parameter - ie $1 = <ip/cider> in the script's commands
then
	#then $1 is null 
	echo "!!! ERROR !!! Missing parameter."
	echo "Please run the script as follows: "
	echo "$ ./enum_ciphers_sslv3.sh <ip/cidr>"
	exit
else
	#run script 
	if [ -f "$targetList" ]; then rm $targetList; fi
	if [ -f "$ResultsSSLv3" ]; then rm $ResultsSSLv3; fi
	if [ ! -d "$resultsDir" ]; then mkdir $resultsDir; fi
	rm ./results/*
	echo " "
	echo "Scanning $1 for open port number: 443"
	echo "Please wait..."
	nmap -n -Pn -p 443 $1 --open -oG - | grep '443' | awk '{print $2}' | grep -vi 'nmap' > $targetList
	echo "Scanning complete, and target list created."
	sleep 1
	lineCount="$( wc -l $targetList | awk '{print $1}')" 
	echo "Number of IPs discovered with port 443 open: $lineCount"	
    #echo "IPs Discovered with Port 443 Open"
	#echo "---------------------------------"
    #cat $targetList #Display the target list 
    echo ""
	echo "Enumerating Ciphers. Please wait..."
	echo "-----------------------------------"
	#read targetList
	while IFS= read -r line
	do
        # Run NMap SSL Enum Script	
		echo " - Checking Ciphers: $line"   
		nmap -sV --script ssl-enum-ciphers -p 443 $line  >> ./results/$line.txt	

	done <"$targetList" 
fi

if [ -f "$targetList" ]; then rm $targetList; fi
grep -Ri 'SSLv3 ' ./results > $ResultsSSLv3
echo ""
echo "Results"
echo "-------"
cat $ResultsSSLv3
echo ""
echo "Logged Results can be found here: $ResultsSSLv3"
echo "Detailed Results can be found here: $resultsDir"
echo ""