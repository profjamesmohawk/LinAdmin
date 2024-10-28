#!/bin/bash

# check for duplicate report_id  in host info reports
#


function usage {
        echo usage: $0 REPORT_FILE REPORT_FILE...
	echo "writes duplicate report file names and report ID to stdout"
}

if (( $# == 0 ))
then
	usage
	exit 1
fi

# grep pattern to find IP line
P='report_id='

TA=$(mktemp) # temp file for complete lines
TDK=$(mktemp) # temp file for duplicate keys

# all IP lines, sorted by ADDR
grep -e $P  $* | sort -k 2 -t = > $TA

# list of addresses appearing more than once
cut -f 2 -d = $TA | uniq -d > $TDK

# interesting lines from $TA 
grep -f $TDK $TA

rm $TA $TDK
