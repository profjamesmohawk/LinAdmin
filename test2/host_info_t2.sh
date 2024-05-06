#!/bin/bash

OUT_FILE=$(hostname)_report_t2.html
rm $OUT_FILE 2>/dev/null

# map stdout to OUT_FILE
#
#exec 1<> $OUT_FILE

################ functions to spit html ################################
#

function spit_pre {
	echo "<html>"
	echo "<head>"
	echo "<style type=\"text/css\">"
	echo "body { font-family: Arial; }"
	echo "table { margin: 1em; border-collapse: collapse; }"
	echo "pre { overflow: auto; display: block; width: 90%; border: 1px solid #ccc; padding: 3px; background: #ece9d8; margin-top: 0px; margin-left: 5px; border-radius: 5px; }"
	echo "td, th { padding: .3em; border: 2px #ccc solid; }"
	echo "</style>"
	echo "</head>"

	echo "<body>"
}

function spit_post {
	echo "</body></html>"
}

function spit_title {
	echo "<h2> $1 </h2>"
}


function start {
	echo ""
	#echo "<strong>${1}</strong>"
	echo "${1}"
	echo -n "<pre>" 
}
function end {
	echo "</pre>"
}

function e3 {
	echo "<hr>"
	#echo "<h3>${1}</h3>"
	#echo "<strong>${1}</strong><br>"
	#echo "<br>"
}
#
################# end html spitters ######################################

{
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

start "Host Info:"
hostname
date
end

start "Is this a fresh VM? (boot history)"
grep -h 'Command line: BOOT' /var/log/messages* | cut -c 1-12 | grep -v Jun| sort -M
end


e3 "Backup (5 points)"

start  "/tmp/etc.tar should have approximately 700 files (1 point)"
tar tf /tmp/etc.tar | wc -l
end

start  "books.cpio: correct files, dates (2 points)"
cpio -tv < /tmp/books.cpio | head -4
end

start "foo.tar correct files, dates (2 points)"
tar vtf /tmp/foo.tar | head -5
end


e3 "NFS (5 points)"


start "NFS Connecton from w01 (1 point)"
netstat -a | grep 'nfs.*w01'
end

start "/nfs/w01 in exports (2 points)"
cat /etc/exports
end

start "Test files in /nfs/w01 (2 points)"
ls -l /nfs/w01
end

e3 "Logging (5 points)"

start "remote logging enabled (1 point)"
grep -e imudp -e imtcp /etc/rsyslog.conf | grep -v '^#'
end

start "contents of /var/log/web.log (2 points)"
tail -5 /var/log/web.log
end

start "authpriv from w01 in /var/log/secure (2 points)"
# improve pattern to not match w01_guest user add message
grep w01 /var/log/secure | tail -10
end

echo "<!-- report_id=$(uuidgen) -->"
} > $OUT_FILE

# squirrel away a copy in a comment
#
TF=$(mktemp)
echo "<!-- altenc" > $TF
cat $OUT_FILE | gzip | base64 >> $TF
cat $TF >> $OUT_FILE

{
echo "altenc -->"

spit_post

} >> $OUT_FILE
