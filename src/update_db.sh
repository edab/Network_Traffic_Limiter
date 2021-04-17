#!/bin/sh

# Table history fields: mac TEXT, timestamp UNSIGNED BIG INT, url TEXT
# Table traffic fields: mac TEXT, timestamp UNSIGNED BIG INT,
#                       app_name VARCHAR(50), cat_name VARCHAR(50),
#                       tx UNSIGNED BIG INT, rx UNSIGNED BIG INT

# Vars ------------------------------------------------------------------------

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)

# Maximum data retained in the DB
DB_DEPTH="14 days"

# Interval in mimutes used for capturing data
UPDATE_INTERVAL="10"

# Databases location
TRAFFIC_DB="/jffs/.sys/TrafficAnalyzer/TrafficAnalyzer.db"
WEB_DB="/jffs/.sys/WebHistory/WebHistory.db"

# Function --------------------------------------------------------------------

check_ps4_mac() {
    echo $(bwdpi device | grep "Sony PlayStation 4" | cut -d '>' -f 1)
}

update_web_db() {
    echo "Log: Deleting old records"
    sqlite3 ${WEB_DB} <<-END_SQL
        DELETE
        FROM history
        WHERE (
            timestamp <
            strftime('%s',date('now','-${DB_DEPTH}','start of day'))
        );
    END_SQL
    echo "Log: Updating web traffic database"
    WebHistory -eget_traffic_db_size() {
    echo $(du -sm ${TRAFFIC_DB} | cut -f 1)
}

get_web_db_size() {
    echo $(du -sm ${WEB_DB} | cut -f 1)
}

get_web_activity() {
    # TODO: add filters by MAC and Date
    echo "Log: printing all web database (sqlite3 ${WEB_DB})"
    sqlite3 ${WEB_DB} <<-END_SQL
        .width auto
        .mode csv
        .headers on
        SELECT mac, datetime(timestamp, 'unixepoch', 'localtime') AS time, url
        FROM history
        ORDER BY timestamp;
    END_SQL
}

get_traffic_activity() {
    # TODO: add filters by MAC and Date
    echo "Log: printing all IP Traffic database (sqlite3 ${TRAFFIC_DB})"
    sqlite3 ${TRAFFIC_DB} <<-END_SQL
        .width auto
        .mode csv
        .headers on
        SELECT mac, datetime(timestamp, 'unixepoch', 'localtime') AS time,
            cat_name, app_name, tx, rx
        FROM traffic
        ORDER BY timestamp;
    END_SQL
}

print_help() {
    echo "AsusWrt Traffic Analisys utility v1.0"
    echo
    echo "Usage: $(basename $0) [-gw|pw|gt|pt]"
    echo
    echo "Handle Web and IP Traffic data"
    echo
    echo "    -gw  --get_web          Update web db with current activity"
    echo "    -pw  --print_web        Print web db"
    echo "    -gt  --get_traffic      Update traffic db with current activity"
    echo "    -pt  --print_traffic    Print traffic db"
    echo "    -u   --update           Update both databases"
    echo "    -d   --daemon           Install daemon"
    echo "    -i   --info             Get information"
    echo "    -h   --help             Get this help screen"
    echo
}

# Main ------------------------------------------------------------------------

if [ $# -eq 0 ]; then

    print_help
    exit 1 # No parameters passed

elif [ "$1" == "--info" ] || [ "$1" == "-i" ]; then

    echo
    TRAFFIC_DB_SIZE=$(get_traffic_db_size)
    TRAFFIC_WEB_SIZE=$(get_web_db_size)
    PS4_DEVICE=$(check_ps4_mac)
    DAEMON=$(cru l | grep UpdateTrafficDBs)

    if [ -z "${DAEMON}" ]; then
        echo "           Daemon: Not installed"
    else
        echo "           Daemon: Installed"
    fi

    echo "  Traffic DB size: ${TRAFFIC_DB_SIZE} MB"
    echo "      Web DB size: ${TRAFFIC_WEB_SIZE} MB"

    if [ ! -z "$PS4_DEVICE" ] && [ "$PS4_DEVICE" == "$MAC_PS4" ]
    then
        echo "              PS4: Present"
    else
        echo "              PS4: Not present"
    fi
    echo

elif [ "$1" == "--daemon" ] || [ "$1" == "-d" ]; then

    DAEMON=$(cru l | grep UpdateTrafficDBs)
    SCRIPT=$(readlink -f $0)

    if [ -z "${DAEMON}" ]; then
        echo "Log: installing daemon"
        cru a UpdateTrafficDBs "*/${UPDATE_INTERVAL} * * * * ${SCRIPT} -u"
    else
        echo "Log: Daemon already installed"
    fi

elif [ "$1" == "--remove" ] || [ "$1" == "-r" ]; then

    DAEMON=$(cru l | grep UpdateTrafficDBs)

    if [ -z "${DAEMON}" ]; then
        echo "Log: Daemon already removed"
    else
        echo "Log: Removing daemon"
        cru d UpdateTrafficDBs
    fi

elif [ "$1" == "--get_web" ] || [ "$1" == "-gw" ]; then

    update_web_db

elif [ "$1" == "--print_web" ] || [ "$1" == "-pw" ]; then

    get_web_activity
    
elif [ "$1" == "--get_traffic" ] || [ "$1" == "-gt" ]; then

    update_traffic_db

elif [ "$1" == "--print_traffic" ] || [ "$1" == "-pt" ]; then

    get_traffic_activity

elif [ "$1" == "--update" ] || [ "$1" == "-u" ]; then

    update_web_db
    update_traffic_db

elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then

    print_help

else

    echo "Error: unknown option passed ($1)"
    exit 2 # Wrong parameter passed

fi

