#!/bin/bash
#
# Check and compare grade reports
#


# set file to check
RF=$1

DIFF_CMD='meld '

F1=$(mktemp)
F2=$(mktemp)

head -n $(grep -ns  -e '<!-- altenc' $RF | cut -f 1 -d :) $RF |grep -v -e '<html>' -e '<head>' -e '<meta' > $F1
tail -n +$(grep -ns  -e '<!-- altenc' $RF | cut -f 1 -d :) $RF | grep -v -e '<' -e '>' | base64 -d | gunzip | grep -v -e '<html>' -e '<head>' -e '<meta'> $F2

S1=$(md5sum < $F1)
S2=$(md5sum < $F2)

if [ "$S1" != "$S2" ]
then
	$DIFF_CMD $F2 $F1
else
	echo "OK"	
fi

rm $F1 $F2
