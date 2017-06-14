#!/bin/bash

set +o allexport
. /etc/milquetoast.conf
set -o allexport

TIMESTAMP=$(date +"%s")
STDOUT_LOG=/var/log/milquetoast_${TIMESTAMP}.log
STDERR_LOG=/var/log/milquetoast_${TIMESTAMP}_error.log

###

/usr/local/bin/milquetoast \
    1>> "$STDOUT_LOG" \
    2>> "$STDERR_LOG"

if ( [ ! $? -eq 0 ] || [ -s $STDERR_LOG ] ); then   
    echo "$MT_MAIL_MESSAGE" | mailx -s "$MT_MAIL_SUBJECT" -a "$STDOUT_LOG" -a "$STDERR_LOG" "$MT_MAIL_TO"
fi
