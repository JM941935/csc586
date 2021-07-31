#!/bin/bash

# this script assumes that apache is installed and running, that /var/webserver_log is mounted,
# and file permissions are correctly set for all files and folders. The script i used to install apache 
# can be found here: https://raw.githubusercontent.com/JM941935/csc586/Assignment-2/webserverSetup.sh

# check if running as root, exit of not
if [[ ! "$EUID" == 0 ]]; then (echo 'please run this script with root privleges' && exit 1); fi

# declare in and out file paths, variables
INLOG="/var/log/auth.log"
OUTLOG="/var/webserver_log/unauthorized.log"
LASTLOGGED=$(tail -1 "$OUTLOG" | awk '{print $3}')
if [ -z "$LASTLOGGED" ]; then LASTLOGGED=0; fi

# extract ip, country, and date from each matching line
# 
# the string "Invalid user" is sufficuent to account for every ssh login attempt, except when the attacker
# tries to login with the username root. I included the string "Disconnected from authenticating user root"
# to account for this. So, between these two strings, every individual attempt can be extracted from auth.log
# without changing the loglevel from INFO to VERBOSE.
cat "$INLOG" | grep -E '(Invalid user)|(Disconnected from authenticating user root)' | while read LINE; do

    # get date
    DATESTRING=$(echo "$LINE" | awk '{printf "%s %s %s", $1, $2, $3}')
    DATE=$(date -d "$DATESTRING" +'%Y%m%d%H%M%S') # format YyyyMmDdHhMmSs (24 hour clock)

    # if date > last entry in log, print
    if (( "$DATE" > "$LASTLOGGED" )); then

        # get IP
        IP=$(echo "$LINE" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')

        # get country (geoiplookup is part of the geoip-bin package)
        COUNTRY=$(geoiplookup "$IP" | cut -c24-25)

        # if country == IP, IP was not found in db
        if [[ "$COUNTRY" == "IP" ]]; then COUNTRY='??'; fi

        # print
        echo "$IP $COUNTRY $DATE" >> "$OUTLOG"
    fi
done

# add cron job to run this script every 5 minutes
(crontab -l | grep -v -F "scan.sh"; echo '*/5 * * * * /users/JM941935/scan.sh') | crontab -

exit 0
