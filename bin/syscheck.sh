#!/bin/bash

echo "--- uptime ---"
uptime

echo "--- memory ---"
free -m

echo "--- disks ---"
df -h | grep '^/dev' | grep -v '^/dev/loop'

echo "--- logins ---"
last | \
    perl -wlne '/(\d+\.\d+\.\d+\.\d+)/ && print $1' | \
    sort | uniq -c | sort -n

echo "--- SSH logins via public key ---"
journalctl -u ssh | grep 'Accepted publickey' | \
    perl -wlne '/(\d+\.\d+\.\d+\.\d+)/ && print $1' | \
    sort | uniq -c | sort -n
