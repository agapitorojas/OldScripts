#!/bin/bash
for X in $(awk '/^server/ && !/127\./ {print $2}' /etc/ntp.conf); do
    ntpdate -q ${X} |head -1 |awk '{print $2,$NF}'
done |sort -k 2 |cut -d, -f1 |head -1 |\
while read Y; do
    service ntpd stop
    ntpdate ${Y}
    service ntpd start
done