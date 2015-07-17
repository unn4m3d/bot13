#!/bin/sh
DATETIME=""

### BEGIN INIT INFO
# Provides: 		bot13
# Description: 		Th1rt3en Bot serv
# Short-Description:	Th1rt3en Bot
# Required-Start:	$syslog
# Required-Stop:
# Default-Start: 	2 3 4 5
# Default-Stop: 	0 1 6
### END INIT INFO

isstarted(){
	if [ ! -f /var/bot13/pid ] || ["$(cat /var/bot13/pid)" -e ""] || ! (ps | grep $(cat /var/bot13/pid)); then
		return 1
	else
		return 0
	fi
}

start(){
	if ! isstarted; then
		DATETIME=$(date "+%Y%m%d%H%M%S")
		p=$PWD
		cd /var/bot13
		ruby ./core.rb > ./log_$DATETIME &
		echo $! > /var/bot13/pid
		echo "Started bot ID $!"
	else
		echo "Bot is already started!"
	fi
}

stop(){
	if isstarted; then
		BOT_PID=$(cat /var/bot13/pid)
		kill "$BOT_PID"
		echo "Killed $BOT_PID"
		rm /var/bot13/pid
	else
		echo "No started bot found"
	fi
}

case "$1" in
	"start")
		start
		;;
	"stop")
		stop
		;;
	"restart")
		stop
		start
		;;
	"status")
		echo "Bot PID : $BOT_PID"
		echo "LOG : "
		cat /var/bot13/bot13_log_$DATETIME
		;;
	*)
		echo "Usage : $0 start|stop|restart|status"
		exit 1
		;;
esac

#exit 0
