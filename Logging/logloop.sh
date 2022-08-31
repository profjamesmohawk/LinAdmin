#!/bin/bash

#
#   Script to run logger in a loop
#
# James Long, Fall 2021
# p.s. I consider this to be a "production quality" script
#

LOGGER_CMD=/usr/bin/logger

# set defaults
#
FACILITY=local6
PRIORITY=DEBUG
MESSAGE=""
SLEEP_TIME=10
N=-1
DB_FILE=bread_crumb.txt
ME=$(basename $0)

# define function to complain and exit
function complain_and_exit(){
	echo $1
	exit 1
} >&2

# define function to spit usage to STDERR
function usage(){
	echo "Usage: $ME [-f FACILITY] [-p PRIORITY] [-m MSG_TXT] [-s SECONDS] [-c N] "
	echo "      -f FACILITY, defaults to local6."
	echo "      -p PRIORITY, defaults to DEBUG."
	echo "      -m MSG_TEXT, text to add to message."
	echo "      -s SECONDS, seconds to sleep between messages."
	echo "      -c N, send N messages then exit.  (N=-1 loops forever)"
	echo " "
	echo "  Bash script to send a series of syslog messages via logger."
	echo "  The series is numbered.  The index is preseved between runs"
	echo "  in the file $DB_FILE."
	echo ""
} >&2

# parse command line args
#
while getopts f:p:m:s:c: name
do
	case $name in
		f)	FACILITY="$OPTARG";;
		p)	PRIORITY="$OPTARG";;
		m)	MESSAGE="$OPTARG";;
		s)	SLEEP_TIME="$OPTARG";;
		c)	N="$OPTARG";;
		?)	usage; exit 1;;
	esac	
done


# verify that DB_FILE is present and sane
#
if [ -f $DB_FILE ]
then
	NDX=$(cat $DB_FILE)
	if ! [[ "$NDX" =~ ^[0-9]+$ ]]
	then
		complain_and_exit "Bad backing file: $DB_FILE"		
	fi	
else
	NDX=0
fi

# make sure we write NDX to DB_FILE when we exit, _almost_ nom matter how we exit
trap '{ echo $NDX > $DB_FILE ; }' EXIT

# read NDX from file, so that we "pick up where we left off"
NDX=$(cat $DB_FILE)

echo "" >&2
echo "Generating logger messages every $SLEEP_TIME seconds. Starting at MSG $NDX" >&2

COUNT=0
while
	true
do

	# build our command
	CMD="$LOGGER_CMD -p ${FACILITY}.${PRIORITY} f $ME:${FACILITY}.${PRIORITY}$NDX:$MESSAGE"

	# run command, and check the return code
	if $CMD 
	then 
		echo $CMD # report progress
	else
		exit 2
	fi

	# inc the index
	(( NDX++ ))

	# have we hit our quota of messages?
	(( COUNT++ ))

	if (( COUNT == N )); then exit 0;fi

	# take a nap
	sleep $SLEEP_TIME
done
