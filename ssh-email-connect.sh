#!/bin/bash
# By Wiesław Magusiak 
# SSH connection to a remote computer at an IP announced through e-mail
# Works only with thunderbird
#
(( $(which thunderbird 2>/dev/null 1>&2; echo $?) )) && { 
	echo "Missing dependency: Install thunderbird.";
	exit
}
VERSION=0.10
PORT=''
sshUSER=$USER
SUBJ="time msg from"

function id-inbox () {
	# Identify tunderbird's inbox containing a subject ($1)
	local SUBJ path0 path1 paths
	SUBJ="$1"
	path0="$HOME/.thunderbird"
	declare -a paths
	paths=$(grep Path= $path0/profiles.ini|cut -d= -f2 2>/dev/null)
	k=0 		# number of inboxes with $SUBJ found.

	for e in ${paths[@]}; do 
		path1="${path0}/${e}/Mail"
		for d in "${path1}"/* ; do
			if [[ -d $d ]]; then
				grep -m1 "$SUBJ" "${d}/Inbox" 1>/dev/null 2>&1; 
				if [[ $? == 0 ]]; then
					INBOX=$d
					((++k))
					[[ $k -gt 1 ]] && { echo "Error code 10"; return 10;}
				fi
			fi
		done
	done
	((k)) && echo $INBOX || { echo "Error code 11" && return 11;}
}

function myip () { 
	if [ -f `whereis curl | cut -d" " -f2` ] ; then 
		IP=$(curl -s ifconfig.me)
		IP=${IP#*: }; IP=${IP%%<*}
	else
		if [ -f `whereis wget | cut -d" " -f2` ] ; then 
			IP=$(wget -q -O - checkip.dyndns.org)
			IP=${IP#*: }; IP=${IP%%<*}
		else
			exit 1
		fi
	fi
	IFACE=$(echo $(ip route)|cut -d" " -f5)
	IP=$IP" "$(ip a show dev $IFACE | awk '$1 == "inet" { split($2, a, "/"); print a[1]; }')
	echo $IP" "$IFACE
}

# ------------- Start --------------------------------------------
if [[ $# > 0 ]] ; then
	USAGE="Usage:\n\t${0##*/} [-p PORT] [-u sshUSER] [-s SUBJECT] [-r remHOST]\
	\n\tDefault sshUSER='$sshUSER', PORT=22.\
	\n\tSee the man pages. (man ssh-email-connect)"
	while getopts  ":p:u:s:r:h" flag
	do
    	case "$flag" in
			p) PORT="-p$OPTARG";;
			u) sshUSER=$OPTARG;;
			s) SUBJ=$OPTARG;;
			r) remHOST=$OPTARG;;
			h) echo -e $USAGE && exit;;
    	esac
	done
fi
# ------------- Is the remote computer on? -----------------------
# E-mail inbox containing messages from a remote computer
[[ ${#remHOST} -gt 0 ]] && SUBJ=${SUBJ}" "${remHOST}
INBOX=$(id-inbox "$SUBJ")
if [[ ${INBOX%% *} == "Error" ]]; then
	echo -n "${INBOX}:  "
	[[ ${INBOX##* } == 11 ]] && echo "No e-mail received." || \
		echo "E-mail messages found in more than one inbox."
	exit ${INBOX##* }
fi
INBOX=$INBOX"/Inbox"

#remIP=$(grep -A7 "$SUBJ" $INBOX | tail -1)
remIP=$(echo $(grep -A12 "$SUBJ" $INBOX | tail -10|sed -n "/^$/,/^$/p"))

if [[ $remIP == 'Shutdown.' || $remIP == 'Close.' ]]; then
	echo The remote computer is switched off.
	exit 1
fi 

LOCAL=$(myip); 
[[ ${remIP%% *} != ${LOCAL%% *} ]] && remIP=${remIP%% *} || {
	remIP=${remIP% *}; remIP=${remIP#* };
	echo The remote computer is on the local network.
}


# ------------- The remote computer is switched on. -------------
echo -e "Connecting...\n\tssh $PORT $sshUSER@$remIP"
ssh $PORT $sshUSER@$remIP
