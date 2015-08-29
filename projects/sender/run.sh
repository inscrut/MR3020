#!/bin/sh
cd /root/sender/
cat /dev/null > send.txt
cat post.txt > send.txt; sed s/MAILTO/$1/g send.txt > buffer; cat buffer > send.txt; sed s/THEME/$2/g send.txt > buffer; cat buffer > send.txt;
cat /dev/null > buffer
cat message >> send.txt
ssmtp $1 < send.txt
cd /
