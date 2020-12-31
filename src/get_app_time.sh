#!/bin/sh

APP_NAME=$1
MAC=$2

MIN_TIME=`sqlite3 /jffs/.sys/TrafficAnalyzer/TrafficAnalyzer.db "SELECT min(timestamp) FROM traffic WHERE (mac LIKE '${MAC}%') AND (timestamp > strftime('%s',date('now','localtime','start of day'))) AND (app_name = '${APP_NAME}')";`
MAX_TIME=`sqlite3 /jffs/.sys/TrafficAnalyzer/TrafficAnalyzer.db "SELECT max(timestamp) FROM traffic WHERE (mac LIKE '${MAC}%') AND (timestamp > strftime('%s',date('now','localtime','start of day'))) AND (app_name = '${APP_NAME}')";`
date -d@$((MAX_TIME - MIN_TIME)) -u +%H:%M:%S
