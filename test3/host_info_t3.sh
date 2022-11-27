#!/bin/bash

OUT_FILE=$(hostname)_report_t3.html

# map stdout to OUT_FILE
#
rm $OUT_FILE 2>/dev/null
exec 1<> $OUT_FILE
C="0"

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
if (( EUID != 0 ))
then
	echo "You must be root to run this script" >&2
	exit 1
fi

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

spit_title "COMP-10018 Host Info Report - Test 3"

spit_start Hostname
hostname
date
spit_end

spit_start "Is this a fresh VM?<br><em>boot history</em>"
grep -h 'Command line: BOOT' /var/log/messages* | cut -c 1-12 | grep -v Jun| sort -M
spit_end

spit_start "s01: ping r01 blue by IP"
if 
ping 10.1.1.1 -c 1 > /dev/null
then
echo OK
(( C++ ))
else
echo Fail
fi
spit_end

spit_start "s01: ping r01 orange by IP"
if 
ping 10.3.1.1 -c 1 > /dev/null
then
echo OK
(( C++ ))
else
echo Fail
fi
spit_end

spit_start "s01: ping s03 by IP"
if 
ping 10.3.1.40 -c 1 > /dev/null
then
echo OK
(( C++ ))
else
echo Fail
fi
spit_end

spit_start "s01: ping s03 by name"
if 
ping s03 -c 1 > /dev/null
then
echo OK
(( C++ ))
else
echo Fail
fi
spit_end

spit_start "s01 Part B (cpio): <br><em>expect about 90</em>"
cpio -t </tmp/conf.cpio  | wc -l
spit_end

spit_start "s01 Part B (tar) first 10 files:"
tar tf /tmp/root_home.tar | head 
spit_end

spit_start "s01 Part C (ssh)"
cat /tmp/ssh_cmd.txt
spit_end




spit_start "Ping count:"
	echo $C
spit_end
 
echo "<!-- $(ip link | grep ether | head -1) -->"

echo "<!-- report_id=$(uuidgen) -->"

echo "<!-- C=$C -->"

spit_post

