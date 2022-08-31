#!/bin/bash

#
# Simple script to calculate pi using the dartboard or Monte Carlo method
# This script is intended to provide a simple CPU intensive job for students
# of Unix.  The math may not be correct.  Do not use this script as
# a reference implementation for the calculation of pi.  
#
# James Long
# james.long5@mohawkcollege.ca
#


function usage {
	echo "Usage: $1 N" >&2
	echo "Calculate pi using the dartboard method with as many throws as possible in N seconds." >&2
	echo "N must be an integer between 1 and 1000" >&2
	echo "" >&2
}


N=$1

# required exactly one arg
#
if (( $# != 1 ))
then
	usage $0
	exit 1
fi



# N must be between 1 and 10
if
	(( N < 1 || N > 10000 ))
then
	usage $0
	exit
fi


j=0
nInside=0
nTotalThrows=0
nThrowsThisSecond=0

#
# setup signal handling
#
BAIL_OUT=false
trap "BAIL_OUT=true; echo; echo $0: SIGHUP received terminating >&2"  SIGHUP 
trap "BAIL_OUT=true; echo; echo $0: SIGINT received terminating >&2"  SIGINT 
trap "BAIL_OUT=true; echo; echo $0: SIGTERM received terminating >&2"  SIGTERM

echo -n "My PID is $$ "
echo "Using the dartboard method for aprox $N seconds  to estimate pi..."

# record the start time
START=$(date +%s)
LAST_DOT=$START

# loop for ever, checking if our time is up every 1000 throws
# (yes a timer would be more efficient)
#
while true
do
	# is our time up? 
	NOW=$(date +%s)
	if (( NOW - START > N ))
	then
		break
	fi

	# have we been asked to terminate?
	if
		$BAIL_OUT
	then
		break
	fi

	
	# write a little something every second so people don't think we're dead
	# and they know how fast we're going
	if ((  NOW - LAST_DOT > 0 ))
	then
		LAST_DOT=$NOW
		echo -e "\tCurrent Speed (throws/sec x1000): $nThrowsThisSecond"
		nThrowsThisSecond=0
	fi

	# do 1000 throws
	i=0
	while (( i++ < 1000 ))
	do

		x=$RANDOM
		y=$RANDOM
	
		if
			((x*x + y*y < 32767**2 ))
		then
			(( nInside++ ))
		fi

		# should we bail-out?
		if
			$BAIL_OUT
		then
			echo -n "warning quiting before work is done..."
			break
		fi
		(( nTotalThrows++ ))
	done 
	(( nThrowsThisSecond++ ))
done

echo
echo -ne "\tpi estimated to be: "
echo  "scale=5;$nInside / $nTotalThrows *4 " | bc -l
echo -ne "\tthrows used (x1000): "
echo "$nTotalThrows / 1000" | bc 
