#!/bin/bash
ORIGIN=origin
BRANCH=telegram

local_upd(){
	if wget http://antifreezze.ddns.neT:1337/bot13/latest.zip; then
		unzip latest.zip /var/bot13
		exit $?
	else
		echo "Can't update from antifreezze.ddns.net:1337"
		exit 1
	fi
}

github_upd(){
	if ping -q -c 1 github.com; then
		wget https://github.com/unn4m3d/bot13/archive/master.zip
		unzip master.zip /var/bot13
		exit $?
	else
		echo "Can't update from github"
		exit 1
	fi
}

case "$1" in
	"-r")
		local_upd
		;;
	"-g")
		github_upd
		;;
	"-h")
		echo "Usage : update {-r|-g|-h}"
		echo "-r Updates bot13 from antifreezze.ddns.net:1337"
		echo "-g Updates bot13 from github"
		echo "-h Prints help"
		;;
	*)	
		echo "Usage : update {-r|-g|-h}"
		exit 1
		;;
esac
