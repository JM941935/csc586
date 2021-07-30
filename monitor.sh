#!/bin/bash

# On observer, create a new script called monitor.sh to monitor /var/webserver_monitor/unauthorized.log.
# If there are new entries, an email should be sent to the admin with the content of these new entries.
# Otherwise, the email simply says "No unauthorized access."
# Create a cron job that runs monitor.sh every hour.

# declare in and out file paths, variables
INLOG="/var/webserver_monitor/unauthorized.log"
BODY="body.txt"
BODYBACKUP="body_bak.txt"
TO="james.f.mcgrath36@gmail.com"
SUBJECT="No unauthorized access"

# if body.txt doesnt exists, make it, else timestamp of last entry
if [ ! -f "$BODY" ]; then touch "$BODY"; else LASTLOGGED=$(tail -1 "$BODY" | awk '{print $3}'); fi

# if lastlogged is null, set it to 0
if [ -z "$LASTLOGGED" ]; then LASTLOGGED=0; fi

# delete backup if it exists
if [ -f "$BODYBACKUP" ]; then rm "$BODYBACKUP"; fi

# create backup of body.txt
mv "$BODY" "$BODYBACKUP"

# for every line that was not already emailed to admin, print to body.txt
cat "$INLOG" |  while read LINE; do

    # get date
    DATE=$(echo "$LINE" | awk '{print $3}')
    
    # if the line date > last record sent, print to body.txt
    if (( "$DATE" > "$LASTLOGGED" )); then
        echo "$LINE" >> "$BODY" 
    fi
done

# email admin with status of brute force shh attempts
NEWSSHATTEMPTS=$(wc -l "$BODY" | awk '{print $1}')
if (( "$NEWSSHATTEMPTS" > 0 )); then

    # notify admin of new ssh login attempts
    SUBJECT="Unauthorized access reported"
    cat "$BODY" | mail -A "$INLOG" -s "$SUBJECT" "$TO"
    rm "$BODYBACKUP"
else
    # notify admin that there were no new ssh login attempts
    echo "" | mail -A "$INLOG" -s "$SUBJECT" "$TO"
    rm "$BODY" && mv "$BODYBACKUP" "$BODY"
fi

# add cron job to run this script every hour
(crontab -l | grep -v -F "monitor.sh"; echo '0 * * * * /users/JM941935/monitor.sh') | crontab -
