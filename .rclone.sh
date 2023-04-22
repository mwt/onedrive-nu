#!/bin/sh

# This script is used to sync my OneDrive folder with my local machine.
# I am notified of any changes via XMPP.

##################
REMOTE_DIR="onedrive-nu:/Referees-Matthew"
MY_XMPP="matthew@xmpp.mwt.me"
SYNC_DIR=$(dirname -- $0)
##################

# Echo the date and time
echo ">>>> Syncing OneDrive at $(date +'[%D %T]') <<<<"

# Change to the directory where the script is located
cd "$SYNC_DIR"

# tell rclone to return error number 9 when nothing is copied
rclone sync --stats 0 --log-file="./.tmp.json" --log-level INFO --use-json-log --error-on-no-transfer "$REMOTE_DIR" "./" --exclude-from ".rcloneignore"
RET_VAL=$?

if [ $RET_VAL -eq 9 ]; then
    echo "nothing changed"
elif [ $RET_VAL -eq 0 ]; then
    # Send a message to my XMPP account
    echo "$MY_XMPP $(date +'[%D %T]') files changed!" | smplxmpp

    # Add username to the begining of a new tmp file (-n means no newline at end of echo)
    echo -n "$MY_XMPP " > "./.tmp"
    # Get the updated files from log file and add them to the tmp file
    jq -sr '[.[] | select(.object != null) | .msg + ": " + .object ] | join("\\n")' "./.tmp.json" >> "./.tmp"
    # Tell smplxmpp to read the tmp file and send the message
    cat "./.tmp" | smplxmpp
    # Delete the tmp file
    rm "./.tmp"
else
    echo "$MY_XMPP $(date +'[%D %T]') Error! rclone exited with code $RET_VAL" | smplxmpp
    # move the log file to a new file with the error code and timestamp
    cp "./.tmp.json" "./.error-$RET_VAL-$(date +'[%D %T]').json"
fi

# Delete the log file
rm "./.tmp.json"
