#!/bin/sh

MAC=$1

# Update blocked lists
nvram set wl0_maclist_x="<${MAC}"
nvram set wl1_maclist_x="<${MAC}"
nvram commit
service restart_wireless

# Get blocked list
MAC_LIST_5G=`nvram get wl1_maclist_x`
MAC_LIST_24G=`nvram get wl0_maclist_x`

echo "-------------------------------------------------------------------"
echo " Blocked list"
echo "-------------------------------------------------------------------"
echo "    5GHz: ${MAC_LIST_5G}"
echo "  2.4GHz: ${MAC_LIST_24G}"
echo "-------------------------------------------------------------------"
