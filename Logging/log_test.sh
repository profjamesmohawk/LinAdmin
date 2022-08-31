#!/bin/bash

# usage

# read command line args
SLEEP_TIME=$1


MSG_ID=local6.debug
DB_FILE=db.txt

#################  end args ##########################

# make sure we write C to DB_FILE when we exit, _almost_ nom matter how
trap '{ echo $C > $DB_FILE ; }' EXIT

# read C from file, so that we "pick up where we left off"
C=$(cat $DB_FILE)

echo "Generating logger messages every $SLEEP_TIME seconds. Starting at MSG $C"
echo "my PID is $$"

while
	true
do

	MSG_TEXT="${MSG_ID} from $0 LT_${C} $(date) "
	echo "sending $MSG_ID $MSG_TEXT"
	logger -p $MSG_ID $MSG_TEXT
	(( C++ ))
	sleep $SLEEP_TIME
done
