#!/bin/bash

# 
# compare primary and alt encoding for grading script reports
#

REPORT_FILE=$1

function usage {
	echo usage: $0 REPORT_FILE
}

if [ ! -f $REPORT_FILE ] || [ "$REPORT_FILE" = "" ]
then
	echo File $REPORT_FILE not found exiting
	usage $0
	exit 1
fi

echo -n "Checking alt encoding for $REPORT_FILE  "

PF=primary.${REPORT_FILE}
AF=alt.${REPORT_FILE}

M1=$(grep -n '^<!-- altenc' $REPORT_FILE | cut -d ':' -f 1)
M2=$(grep -n '^altenc -->' $REPORT_FILE  | cut -d ':' -f 1)

(( BEFORE = M1 - 1 ))
(( ENC_START = M1 + 1))
(( ENC_LEN = M2 - ENC_START ))


# 
# grab just the primary encodeing
#
head -n $BEFORE $REPORT_FILE > $PF
echo "</body></html>" >> $PF

#
# grab and expand the alt encoding
#
tail -n +$ENC_START $REPORT_FILE | head -n $ENC_LEN | base64 -d | gunzip > $AF
echo "</body></html>" >> $AF

# 
# compare primary and alt versions
#
if 
	cmp --quiet $PF $AF
then
	echo "pass"
	# files matched, so we can clean up
	rm $PF $AF
else
	echo "fail try: meld $PF $AF"
fi
