#!/bin/bash

OUT_FILE=$(hostname)_report_t3.html

C="0"

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


function spit_start {
        echo ""
        #echo "<strong>${1}</strong>"
        echo "${1}"
        echo -n "<pre>" 
}
function spit_end {
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


#
# are we root?
#
if (( EUID != 0 ))
then
	echo "You must be root to run this script" >&2
	exit 1
fi
{
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
journalctl --since="2024-01-01" | grep 'Command line:' | cut -c 1-12
spit_end

spit_start "Where are we"
        curl -x 10.1.1.10:8888 -s "https://csunix.mohawkcollege.ca/~long/php/what_is_my_ip.php"  | grep client
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

