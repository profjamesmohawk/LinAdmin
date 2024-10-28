#!/bin/bash

# pull list of unique IP address lines from a set of
# Lin Admin test reports
#


function usage {
        echo usage: $0 REPORT_FILE REPORT_FILE...
	echo "	Write list of unique IP addresses to stdout."
	echo "	Help from IT will be required to map addresses to rooms."
	echo "	For now we have to look for \"a dog in a hat\"."
}

if (( $# == 0 ))
then
	usage
	exit 1
fi

# grep pattern to find IP line
P='client='


# all IP lines, sorted by ADDR
grep -e $P  $* | cut -f 2 -d = | sort -u | sort -t \. -k 1,1n -k 2,2n -k 3,3n -k 4,4n

