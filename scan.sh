#!/bin/bash

# On webserver, Create a shell script called scan.sh that will scan the webserver's auth.log file for unauthorized/failed SSH access.
# Based on the IP information, scan.sh should also identifies the country of origin of this IP address automatically.
# The resulting information should be appended to a file called unauthorized.log inside
# the NFS-mounted /var/webserver_log with the following format: IP_ADDRESS COUNTRY DATE.
# Create a cron job that will execute this script every 5 minutes.

# declare in and out file paths, variables
INLOG="auth.log" # "/var/log/auth.log"
OUTLOG="unauthorized.log" # "/var/webserver_log/unauthorized.log"
OLDLOGSIZE=$(wc -l "$OUTLOG" | awk '{print $1}')
LASTLOGGED=$(tail -1 "$OUTLOG" | awk '{print $3}')
if [ -z "$LASTLOGGED" ]; then LASTLOGGED=0; fi
TOTALSSHATTEMPTS=$(cat "$INLOG" | grep -c "Invalid user")
EXECUTOR=$(whoami)
EXECUTEDDATE=$(date +'%Y%m%d%H%M%S')

# extract ip, country, and date from each matching line
cat "$INLOG" | grep "Invalid user" | while read LINE; do
    DATESTRING=$(echo "$LINE" | awk '{printf "%s %s %s", $1, $2, $3}')
    DATE=$(date -d "$DATESTRING" +'%Y%m%d%H%M%S') # format YyyyMmDdHhMmSs (24 hour clock)

    # if date > lastlogged, print to log
    if (( "$DATE" > "$LASTLOGGED" )); then
        IP=$(echo "$LINE" | awk '{print $10}')
        COUNTRY=$(geoiplookup $IP | cut -c24-25)

        # if country == IP, IP was not found in db
        if [[ "$COUNTRY" == "IP" ]]; then COUNTRY='??'; fi
        echo "$IP $COUNTRY $DATE" >> "$OUTLOG"
    fi
done

# print job info to log
NEWLOGSIZE=$(wc -l "$OUTLOG" | awk '{print $1}')
NEWSSHATTEMPTS=$(($NEWLOGSIZE-$OLDLOGSIZE))
echo "$EXECUTOR $EXECUTEDDATE $TOTALSSHATTEMPTS $NEWLOGSIZE $OLDLOGSIZE $NEWSSHATTEMPTS" >> scan.log

# add cron job to run this script every 5 minutes
(crontab -l | grep -v -F "scan.sh"; echo '*/5 * * * * /users/JM941935/scan.sh') | crontab -
