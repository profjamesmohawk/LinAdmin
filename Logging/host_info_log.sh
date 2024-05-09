#!/bin/bash

OUT_FILE=$(hostname)_report_log.html

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

spit_title "COMP-10018 Host Info Report - Logging"

spit_start Hostname
hostname
date
spit_end

# send all the log messages we will use
logger -p mail.error "FM_T1: mail.error"
logger -p mail.debug "FM_T2: mail.debug"
logger -p cron.error "FM_T3: cron.error"

# sleep to give rsyslog time to write, (looks like rsyslog writes twice a second)
sleep 1

spit_start "Part B.1,  (2 points) <br> FM_T1 in maillog, mail_warn, and msg_err"
grep -l FM_T1 $(find /var/log/ -type f)
spit_end

spit_start "Part B.1,  (2 point) <br> FM_T2 in maillog"
grep -l FM_T2 $(find /var/log/ -type f)
spit_end

spit_start "Part B.1,  (2 point) <br> FM_T3 in cron, msg_err"
grep -l FM_T3 $(find /var/log/ -type f)
spit_end

spit_start "Part C: (2 points) <br> authpriv messages from s02 in /var/log/secure"
grep s02 /var/log/secure 
spit_end

spit_start "Part D: (2 points) <br> http errors in /var/log/messages"
grep httpd /var/log/messages | tail -5
spit_end


spit_post
