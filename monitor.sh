#!/bin/bash

# this script assumes that nfs-kernel-server and mailutils are installed and configured, and that
# all files and folders have the correct permissions set. the script i used to install and configure this
# vm can be found here: https://raw.githubusercontent.com/JM941935/csc586/Assignment-2/observerSetup.sh

# check if running as root, exit of not
if [[ ! "$EUID" == 0 ]]; then (echo 'please run this script with root privleges' && exit 1); fi

# declare in and out file paths, variables
INLOG="/var/webserver_monitor/unauthorized.log"
BODY="body.txt"
BODYBACKUP="body_bak.txt"
TO="james.f.mcgrath36@gmail.com"
SUBJECT="No unauthorized access"

# if body.txt doesnt exists, make it, else get timestamp of last entry
if [ ! -f "$BODY" ]; then touch "$BODY"; else LASTLOGGED=$(tail -1 "$BODY" | awk '{print $3}'); fi

# if lastlogged is null, set it to 0
if [ -z "$LASTLOGGED" ]; then LASTLOGGED=0; fi

# delete backup if it exists
if [ -f "$BODYBACKUP" ]; then rm "$BODYBACKUP"; fi

# create backup of body.txt
mv "$BODY" "$BODYBACKUP"

# for every line in unauthorized.log, check if the date is newer than $LASTLOGGED
cat "$INLOG" |  while read LINE; do

    # get date
    DATE=$(echo "$LINE" | awk '{print $3}')
    
    # if the date is newer than $LASTLOGGED, print to body.txt
    if (( "$DATE" > "$LASTLOGGED" )); then
        echo "$LINE" >> "$BODY" 
    fi
done

# email admin with the results
NEWSSHATTEMPTS=$(wc -l "$BODY" | awk '{print $1}')
if (( "$NEWSSHATTEMPTS" > 0 )); then

    # notify admin of new ssh login attempts
    SUBJECT="Unauthorized access reported"
    cat "$BODY" | mail -A "$INLOG" -s "$SUBJECT" "$TO"    
    rm "$BODYBACKUP"    
else
    # notify admin that there were no new ssh login attempts
    cat "$BODY" | mail -A "$INLOG" -s "$SUBJECT" "$TO"
    rm "$BODY" && mv "$BODYBACKUP" "$BODY"
fi

# add cron job to run this script every hour
(crontab -l | grep -v -F "monitor.sh"; echo '0 * * * * /users/JM941935/monitor.sh') | crontab -

exit 0
