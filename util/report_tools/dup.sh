#!/bin/bash

PH="bad_hash"
PF="x"
FM="1"



{
for F in $(ls *html)
do
	md5sum $F 
done
} | \
tee ttt | \
sort | \
while
	read H F
do
	if [ "$PH" = "$H" ]
	then
		if [ $FM = "1" ]
		then
			echo 
			echo $PF $PH
			FM="0"
		fi
		echo $F $H
	else
		FM="1"
	fi

	PF=$F
	PH=$H	
done
