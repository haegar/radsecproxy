#! /bin/sh

### BEGIN INIT INFO
# Provides:		radsecproxy
# Required-Start:	$remote_fs $syslog $network
# Required-Stop:	$remote_fs $syslog
# Should-Start:		$time $named
# Should-Stop:		
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	RADIUS proxy
# Description:		RADIUS protocol proxy supporting RadSec
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/radsecproxy
DAEMONUSER=radsecproxy
NAME=radsecproxy
DESC="RadSec proxy"
PIDDIR=/run/$NAME
PIDFILE=$PIDDIR/pid

. /lib/lsb/init-functions

test -x $DAEMON || exit 0

DAEMON_OPTS="-i $PIDFILE"

case "$1" in
  start)
	if [ ! -d $PIDDIR ]; then
		mkdir -p $PIDDIR
		chown $DAEMONUSER $PIDDIR
		chgrp $DAEMONUSER $PIDDIR
	fi

	if pidofproc -p $PIDFILE $DAEMON > /dev/null; then
		log_failure_msg "Starting $DESC (already started)"
		exit 0
	fi
	if ! $DAEMON -p $DAEMON_OPTS 2> /dev/null; then
		log_failure_msg "Checking $DESC config syntax"
		exit 1
	fi
	log_daemon_msg "Starting $DESC" "$NAME"
	start-stop-daemon --start --quiet --pidfile $PIDFILE \
		--user $DAEMONUSER --chuid $DAEMONUSER \
		--exec $DAEMON -- $DAEMON_OPTS
	log_end_msg $?
	;;
  stop)
	log_daemon_msg "Stopping $DESC" "$NAME"
	start-stop-daemon --stop --retry 5 --quiet --pidfile $PIDFILE \
		--user $DAEMONUSER \
		--exec $DAEMON
	case "$?" in
		0) log_end_msg 0 ;;
		1) log_progress_msg "(already stopped)"
		   log_end_msg 0 ;;
		*) log_end_msg 1 ;;
	esac
	;;
  force-reload|restart)
	if ! $DAEMON -p $DAEMON_OPTS 2> /dev/null; then
		log_failure_msg "Checking $DESC config syntax"
		exit 1
	fi
	$0 stop
	$0 start
	;;
  status)
	status_of_proc -p $PIDFILE $DAEMON $NAME && exit 0 || exit $?
	;;
  *)
	echo "Usage: ${0} {start|stop|restart|force-reload|status}" >&2
	exit 1
	;;
esac
