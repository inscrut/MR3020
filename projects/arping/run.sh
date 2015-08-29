#!/bin/sh
cd /root/arping

arp -a > buffer
cat buffer | awk {'print($4)'} >> mac.txt
cat mac.txt | sort | uniq > buffer
cat buffer > mac.txt

cat mac.txt | tr ':' '-' | grep - | awk -F'-' {'print($1$2$3)'} | tr a-z A-Z > buffer
while read line; do echo "`cat oui.txt | grep $line | cut -c3-8,24- >> id.txt`"; done < buffer

cat id.txt | sort | uniq > buffer
cat buffer > id.txt

cat /dev/null > buffer

cd /
