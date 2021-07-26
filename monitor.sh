#!/bin/bash

# On observer, create a new script called monitor.sh to monitor /var/webserver_monitor/unauthorized.log.
# If there are new entries, an email should be sent to the admin with the content of these new entries.
# Otherwise, the email simply says "No unauthorized access."
# Create a cron job that runs monitor.sh every hour.

# install mailutils if its not already installed
dpkg -s "mailutils" &> /dev/null
if [ ! $? -eq 0 ]; then
    apt-get install mailutils
fi

# if email.txt exists, get the date from the last line and create a backup
# else set the date to 0
if [ -f "./email.txt" ]; then

    # get date of the last record sent to the admin
    LASTLINE=$(tail -1 "./email.txt")
    EDATE=$(echo "$LASTLINE" | sed -r 's/^.*([0-9]{14})$/\1/')

    # create a temporary backup
    mv "./email.txt" "./email_bak.txt"
else

    # will match every line in unauthorized.log
    EDATE=0
fi

# echo each line with a greater date into a new email.txt file
cat "/var/webserver_monitor/unauthorized.log" |  while read LINE; do

    # get the date string from the end of the line
    LDATE=$(echo "$LINE" | sed -r 's/^.*([0-9]{14})$/\1/')

    # if the line date > last record sent, it is new, echo into email.txt
    if (( "$LDATE" > "$EDATE" )); then
        echo "$LINE" >> "./email.txt" 
    fi
done

# if email.txt exists, send its contents to the admin
# else send an email with no body
TO="admin.localdomain"
if [ -f "./email.txt" ]; then

    # email the contents of email.txt to the admin
    SUBJECT="Unauthorized access reported"
    echo "$MESSAGE" | mail -p -s "$SUBJECT" "$TO"

    # remove the backup
    rm "./email_bak.txt"
else
    # email admin with just a subject line
    SUBJECT="No unauthorized access"
    echo "" | mail -p -s "$SUBJECT" "$TO"

    # rename the backup and leave it
    mv "./email_bak.txt" "./email.txt"
fi

# add cron job to run this script every hour
(crontab -l | grep -v -F "monitor.sh";echo '0 * * * * /users/JM941935/monitor.sh') | crontab -
