#!/bin/bash

# On webserver, Create a shell script called scan.sh that will scan the webserver's auth.log file for unauthorized/failed SSH access. 
# Based on the IP information, scan.sh should also identifies the country of origin of this IP address automatically. 
# The resulting information should be appended to a file called unauthorized.log inside 
# the NFS-mounted /var/webserver_log with the following format: IP_ADDRESS COUNTRY DATE.
# Create a cron job that will execute this script every 5 minutes.

# install geoip if its not already installed
dpkg -s "geoip-bin" &> /dev/null
if [ ! $? -eq 0 ]; then
    apt-get install geoip-bin
fi

# if webserver_log doesnt exist, make it
if [ ! -d "/var/webserver_log" ]; then
    mkdir "/var/webserver_log"
fi

# declare in and out file paths
INLOG="/var/log/auth.log"
OUTLOG="/var/webserver_log/unauthorized.log"

# extract ip, country, and date from each matching line
cat "$INLOG" | grep "Invalid user" | while read LINE; do

    # extract IP address
    IP=$(echo "$LINE" | sed -r 's/^.*([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*$/\1/')

    # get country with geoiplookup
    COUNTRY=$(geoiplookup $IP)

    # extract and convert date to format YyyyMmDdHhMmSs (24 hour clock)
    DATESTRING=$(echo "$LINE" | sed -r 's/^(.*)localhost.*/\1/')
    DATE=$(date -d "$DATESTRING" +'%Y%m%d%H%M%S')

    # echo result into unauthorized.log
    echo "$IP ${COUNTRY:23} $DATE" >> "$OUTLOG"
done

# add cron job to run this script every 5 minutes
(crontab -l | grep -v -F "scan.sh";echo '*/5 * * * * /users/JM941935/scan.sh') | crontab -
