#!/bin/sh

T=$(date -Iseconds | tr : - | tr + - | tr T - | awk -F- {'print($4$5$6)'})
screen -AdmS blink_$T /root/blink/while.sh
