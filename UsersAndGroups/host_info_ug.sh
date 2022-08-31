#!/bin/bash

OUT_FILE=$(hostname)_report_ug.html

# map stdout to <hostname>_report_ug.html
#
rm $OUT_FILE 2>/dev/null
exec 1<> $OUT_FILE

################ functions to spit html ################################
#
function spit_start {
	echo "<tr>"
	echo "<td valign=\"top\"> $1 </td>"
	echo "<td><pre>"
	echo " "

	# tell the user what we are up to
	echo "Collecting Info for $1" | sed -e 's/<.*>//g' >&2
}

function spit_end {
	echo " "
	echo "</pre>"
	echo "</td>"
	echo "</tr>"
}

function spit_pre {
	echo "<html>"
	echo "<head>"
	echo "<style type=\"text/css\">"
	echo "table { margin: 1em; border-collapse: collapse; }"
	echo "td, th { padding: .3em; border: 2px #ccc solid; }"
	echo "</style>"
	echo "</head>"

	echo "<body><table>"
}

function spit_post {
	echo "</table></body></html>"
}

function spit_title {
	echo "<h2> $1 </h2>"
}

function spit_section_header {
	echo "<tr><td colspan=\"2\"> $1 </td></tr>"
}
#
################# end html spitters ######################################

#
# are we root?
#
#if (( EUID != 0 ))
#then
	#echo "You must be root to run this script" >&2
	#exit 1
#fi

#
# Tell the nice people what we are going to do
#
echo "This script will collect interesting data from your system" >&2
echo "The results will be placed in $OUT_FILE, feel free to have a look." >&2
echo "The best way to view it is a full browser, but lynx will do in a pinch." >&2
echo "Be patient, it could take a few minutes to run." >&2


#
# from here it's a mix is spits and commands
#
#
spit_pre

spit_title "COMP-10018 Host Info Report - Users And Groups"

spit_start Hostname
hostname
date
spit_end

spit_start "Check /etc/skell"
ls  /etc/skel
cat /etc/skel/welcome.txt
spit_end


spit_start "Check for users and groups"
for N in eddy nairo bill carlos
do
	id $N
done
spit_end

spit_start "Check for shared directories"
ls -l /share
spit_end


spit_start "Check for ReadMe files"
ls -l /share/*/ReadMe
echo " "
cat /share/*/ReadMe
spit_end


spit_start "Check for Aging just a spot check"
echo nairo
chage -l nairo | grep -e 'Pas.*expires' -e Maximum
echo
echo carlos
chage -l carlos | grep -e 'Pas.*expires' -e Maximum
spit_end

spit_start "Check for user lock just a spot check"
passwd -S eddy	| cat
passwd -S bill | cat
spit_end

spit_post

$date
