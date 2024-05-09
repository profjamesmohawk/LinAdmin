#!/bin/bash

OUT_FILE=$(hostname)_report_t1.html
rm $OUT_FILE 2>/dev/null

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


function check_hash {
	USER_NAME=$1
	PW=$2
	
	OLD_IFS=$IFS
	IFS=\$

	# read the pw record into vars
	read GARBAGE A S H <<< $( grep $USER_NAME /etc/shadow | cut -f 2 -d :  )
	if [ "$GARBAGE" == "" ] 
	then
		echo user not found
		IFS=$OLD_IFS
		return
	fi

	# check the hash
	#
	read GARBAGE A S NEW_HASH <<< $(openssl passwd -$A -salt $S -stdin <<< $PW )
	echo -n "hash for $USER_NAME "
	if [ "$NEW_HASH" == "$H" ]
	then
		echo -n matches
	else
		echo -n does not match
	fi

	echo " $PW"
	IFS=$OLD_IFS
}

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

spit_title "COMP-10018 Host Info Report - Test 1"

start "Hostname and date"
hostname
date
end

start "Is this a fresh VM?(boot history)"
journalctl --since="2024-01-01" | grep 'Command line:' | cut -c 1-12
end

start "Where are we"
	curl -x 10.1.1.10:8888 -s "https://csunix.mohawkcollege.ca/~long/php/what_is_my_ip.php"  | grep client
end

start "Users And Groups (3 points)"
echo "<strong>groups:</strong>"
id andy
id amita
echo ""
echo "<strong>aging:</strong>"
chage -l andy | grep 'Last'
chage -l amita | grep 'Last'
echo ""
echo "<strong>passwords:</strong>"
check_hash andy mohawk1
check_hash amita mohawk1
end


start "Add a Disks (3 points)"

echo "<strong>vgConfig:</strong>"
vgdisplay -v vgWeb | grep -e 'PV Name' -e 'VG Size' -e 'Free PE'

echo ""
echo "<strong>mounted:</strong>"
df -h | grep -e 'vgWeb' -e '/mnt/web'
echo ""
echo "<strong>fstab:</strong>"
grep web /etc/fstab

end

start "Share /mnt/web (2 points)"
ls -ld /mnt/web
end

start "Install Apache (3 points)"
echo "<strong>installed:</strong>"
yum list httpd
echo ""
echo "<strong>startup:</strong>"
systemctl list-unit-files httpd.service
echo ""
echo "<strong>running:</strong>"
systemctl status httpd
end


start "Welcome Page (2 points)"
wget http://localhost -q -O - | grep -i -e 'andy' -e 'amita'
end

start "Apache Gets Nights Off (2 points)"
cat /etc/cron.d/[wW]eb
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


