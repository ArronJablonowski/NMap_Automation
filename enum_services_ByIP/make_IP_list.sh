#!/bin/bash
# This script will run NMap to create a list of targetes then check the list of targets for SSLv3 ciphers. 
# example: ./make_IP_list.sh
# Author: Arron Jablonowski 
# Last Updated: 2024.10.22

targetList="./targetList_182.txt"

for i in {0..254} #IP Range s
do
    echo "10.10.10.$i" >> ./$targetList
done