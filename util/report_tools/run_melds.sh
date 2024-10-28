#
# Run interactive scans of reports in the current dir that failed integrity check.
# Reports flagged by the user will have a .flag file created.
# Assumes integrity_check.sh ran and .pri and .alt files are present
#
# James, Fall 2024
#

for F in $(ls *.alt)
do
	BF=$(basename -s .alt $F)

	meld ${BF}.alt ${BF}.pri
	
	echo -n "enter f to flag $BF: "

	read A
	if [  "$A" = "f" ]
	then
		touch ${BF}.flag
	fi

done
