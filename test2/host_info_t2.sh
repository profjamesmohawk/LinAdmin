#!/bin/bash

OUT_FILE=$(hostname)_report_t2.html

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

spit_title "COMP-10018 Host Info Report - Test 2"

spit_start Hostname
hostname
date
spit_end

spit_section_header "Part B: Backup (2 points)"

spit_start "tar ball exists (1 point)<br>should have around 700 files"
tar tf /tmp/etc.tar | wc -l
spit_end

spit_start "tar ball containts /etc (1 point)<br>look at first 4 files"
tar tf /tmp/etc.tar | head -4
spit_end

spit_section_header "Part C: NFS (5 points)"

spit_start "NFS Startup (1 point)"
systemctl is-enabled nfs-server 
spit_end

spit_start "NFS Connecton from w01 (1 point)"
netstat -a | grep 'nfs.*w01'
spit_end

spit_start "/nfs/w01 in exports (2 points)"
cat /etc/exports
spit_end

spit_start "Test files in /nfs/w01 (1 point)"
ls -l /nfs/w01
spit_end

spit_section_header "Part D: Logging (5 points)"

spit_start "remote logging enabled (2 points)"
grep -e imudp -e imtcp /etc/rsyslog.conf | grep -v '^#'
spit_end

spit_start "anything in /var/log/httpd.err (1 point)"
wc -l /var/log/httpd.err 
spit_end

spit_start "http errors from w01 in <br>/var/log/httpd.err (2 points)"
grep w01 /var/log/httpd.err | tail -2
spit_end

spit_section_header "Part E: Incremental Backup (2 points)"

spit_start "Incremental tar ball exists (1 point)"
tar tf /tmp/changes.tar | wc -l
spit_end

spit_start "Incremental tar ball contents (1 point)"
tar tf /tmp/changes.tar | tail -20
spit_end

echo "<!-- report_id=$(uuidgen) -->"
$date

spit_post

