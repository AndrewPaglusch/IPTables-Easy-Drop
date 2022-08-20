#!/bin/sh

#Sanity check on arguments
if [ $# -ne 1 ]; then
	echo "Invalid arguments!"
	echo "USAGE: ./drop.sh 1.2.3.4"
	echo "       ./drop.sh 1.2.0.0/16"
	exit 1
fi

#Check for a "blocks" chain.
if ! iptables -t raw -n -L | grep -q 'Chain blocks'; then
    iptables -t raw -N blocks
fi

#Check for a jump to "blocks" chain in "PREROUTING".
if ! iptables -t raw -C PREROUTING -j blocks 2>/dev/null; then
    iptables -t raw -I PREROUTING -j blocks
fi

#Check for a RETURN at end of "blocks" chain.
if ! iptables -t raw -C blocks -j RETURN 2>/dev/null; then
    iptables -t raw -A blocks -j RETURN
fi

#Check to see if already dropped
if iptables -t raw -C blocks -s "$1" -j DROP -m comment --comment "BLOCK $1" 2>/dev/null; then
    echo "$1 appears to already be dropped!"
    exit 2
fi

#Add the IP block
printf "Dropping $1 ... "
if iptables -t raw -I blocks -s "$1" -j DROP -m comment --comment "BLOCK $1" 2>/dev/null; then
    printf "DONE\n"
else
    printf "FAILED\n"
fi

#How to remove a block
# 1) List rules with line numbers
# iptables -t raw -L blocks --line-numbers
# 2) Remove block by line number
# iptables -t raw -D blocks <<linenum>>

