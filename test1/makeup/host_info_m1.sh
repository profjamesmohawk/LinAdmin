#!/bin/bash

OUT_FILE=$(hostname)_report_t1.html

# map stdout to OUT_FILE
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

spit_title "COMP-10018 Host Info Report - Test 1 (Make up)"

spit_start Hostname
hostname
date
spit_end

spit_start "Users And Groups (3 points)"
id andy
id amita
echo ""
echo "aging:"
chage -l andy | grep 'Last'
chage -l amita | grep 'Last'
spit_end


spit_start "Add a Disks (3 points)"

echo "vgConfig:"
vgdisplay -v vgWeb | grep -e 'PV Name' -e 'VG Size' -e 'Free PE'

echo ""
echo "mounted:"
df -h | grep -i -e 'vgWeb' -e '/webadmin'
echo ""
echo "fstab:"
grep html /etc/fstab

spit_end

spit_start "Install Apache (3 points)"
echo "installed:"
yum list httpd
echo ""
echo "startup:"
chkconfig --list httpd
echo ""
echo "running:"
service httpd status
spit_end


spit_start "Welcome Page (2 points)"
wget http://localhost -q -O - | grep -i -e 'andy' -e 'amita'
spit_end

spit_start "Apache Gets Nights Off (2 points)"
cat /etc/cron.d/[wW]eb
spit_end

echo "<!-- report_id=$(uuidgen) -->"
$date

spit_post

