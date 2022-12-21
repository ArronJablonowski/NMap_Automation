#!/bin/bash 
# ABOUT: 
#   This script will monitor and map a network, constantly looking for new hosts to scan with NMap. 
#   NMap scan results will be in the "Results" folder. 
#   Espeak will anounce when a new host is discoverd
#
# EXAMPLE USAGE: 
#    ./NetworkMonitor./sh 192.168.1.0/24 
#    ./NetworkMonitor./sh 192.168.1.0/24 DumpArp
#
# To background the script as a job:
#    ./NetworkMonitor./sh 192.168.1.0/24 &   
#
# DEPENDENCIES: 
#   Nmap 
#   Espeak 
#

# Accepts input as the first argument of the script
cidr=$1
dumpArp=$2

# Temp file to hold list of live hosts (nmap -sn)
pingScanResults="./results/pingscan.txt"
arpTable="./results/arpTable.txt"
tempFile="./results/temp.txt"

# Directory Names to host results 
resultsDir="./results" #results dir 
# nslookupDir="./nsLookup" #nslookup dir 

#directories 
if [ ! -d "$resultsDir" ]; then mkdir $resultsDir; fi # Make dir to hold NMap results if it does not exit 

# Function to pull the ARP table to find hosts that do not respond to ping (ICMP echo requests) 
addArp() {
    echo "Adding Hosts from Arp Table"
    echo "==========================="
    arp -a | grep -v ? | cut -d ' ' -f 1 > $arpTable
    cat $arpTable # display in CLI 
    cat $arpTable >> $pingScanResults #append arp results to ping scan results 
    echo " "
    cat $pingScanResults | sort | uniq > $tempFile # Unique the host names and create a temp file 
    cat $tempFile > $pingScanResults # overwrite with contents of temp file 
    echo " "  
}

# While loop to monitor the network for new hosts. 
while true ; do # Continuous 
    clear 
    echo " "
    echo "Scanning: $1"
    echo " "
    echo "Discovered Live Hosts"
    echo "====================="
    nmap -sn $1 | grep Nmap | grep -v Starting | grep -v done: | cut -d ' ' -f 5 | tee $pingScanResults
    echo " "
    
    if [ "$dumpArp" = "DumpArp" ]; then 
        addArp # Call addArp function 
    fi        

    sleep 2s 

    while IFS= read -r line
    do	
        if [ ! -f "./results/$line.txt" ]; then 
            # nslookup 
            # nslookup $line | grep name >> ./nsLookup/nslookup.txt

            # Announce New Host Found 
            espeak "New Host Discovered."

            # Run NMap SSL Enum Script	 
            echo " + Running Port Scan on: $line"   
            nmap -A -Pn $line -vv --reason >> ./results/$line.txt

        else
            echo " - Skipping Port Scan on: $line" 
            echo " --- Port Scan Already Exists: ./results/$line.txt"    

        fi
    done <"$pingScanResults"

    echo " "
    echo "Sleeping..."
    sleep 60s # Sleep for 60 seconds before scanning network range again. 
    
done 