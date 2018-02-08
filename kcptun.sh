#!/bin/bash

#
# KCPTun       Startup script for the KCPTun Server
#
# chkconfig: - 90 10
# 
# description: The KCPTun is a secure tunnel based On KCP with N:M Multiplexing. \
#              (https://github.com/xtaci/kcptun)
# processname: kcptun
# config: /etc/sysconfig/kcptun
# pidfile: /var/run/kcptun.pid
# 

### BEGIN INIT INFO
# Provides: KCPTun
# Required-Start: $network $syslog $local_fs $remote_fs $named
# Required-Stop: $network $local_fs $remote_fs 
# Should-Start: 
# Should-Stop:        
# Default-Start:      
# Default-Stop:  
# Short-Description: Start and stop KCPTun Server
# Description: The KCPTun is a secure tunnel based On KCP with N:M Multiplexing.
### END INIT INFO


# Author: farawayzheng <http://blog.csdn.net/farawayzheng_necas>
# 
# To install:
#   Copy this file to /etc/rc.d/init.d/kcptun
#   $ chkconfig --add kcptun
#
#
# To uninstall:
#   $ chkconfig --del kcptun
#   

#export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt/bin:

BASE=$(basename $0)

# modify these in /etc/sysconfig/$BASE (/etc/sysconfig/kcptun)
KCPTUN=/root/kcptun/server_linux_amd64

KCPTUN_PIDFILE=/var/run/$BASE.pid
KCPTUN_LOGFILE=/var/log/$BASE.log
KCPTUN_LOCKFILE=/var/lock/subsys/$BASE
KCPTUN_OPTS="-l :1000 -c /root/kcptun/server-config.json"
KCPTUN_DESC="KCPTUN"

# Source function library.
. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/$BASE ]; then
    . /etc/sysconfig/$BASE
fi

# Check kcptun server is present
if [ ! -x $KCPTUN ]; then
    echo "$KCPTUN not present or not executable!"
    exit 1
fi

RETVAL=0
STOP_TIMEOUT=${STOP_TIMEOUT-10}

start() {

    if [ -f ${KCPTUN_LOCKFILE} ]; then

        if [ -s ${KCPTUN_PIDFILE} ]; then
            echo "$BASE might be still running, stop it first!"
            killproc -p ${KCPTUN_PIDFILE} -d ${STOP_TIMEOUT} $KCPTUN
        else
            echo "$BASE was not shut down correctly!"
        fi

        rm -f ${KCPTUN_PIDFILE} ${KCPTUN_LOCKFILE}
        sleep 2
    fi

    echo -n $"Starting $BASE: "
    $KCPTUN --log ${KCPTUN_LOGFILE} $KCPTUN_OPTS &
    RETVAL=$?

    if [ "$RETVAL" = "0" ]; then
        success
        sleep 2
        ps -A o pid,cmd | grep "$KCPTUN --log ${KCPTUN_LOGFILE} $KCPTUN_OPTS" | awk '{print $1}' | head -n 1 > ${KCPTUN_PIDFILE} 
    else
        failure
    fi
    echo

    [ $RETVAL = 0 ] && touch ${KCPTUN_LOCKFILE}
    return $RETVAL
}

stop() {
    echo -n $"Stopping $BASE: "
    killproc -p ${KCPTUN_PIDFILE} -d ${STOP_TIMEOUT} $KCPTUN
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f ${KCPTUN_PIDFILE} ${KCPTUN_LOCKFILE}
    return $RETVAL
}


case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status -p ${KCPTUN_PIDFILE} $KCPTUN
        RETVAL=$?
        ;;
  restart)
        stop
        start
        ;;
  *)
        echo $"Usage: $BASE { start | stop | restart | status }"
        RETVAL=2
        ;;
esac

exit $RETVAL