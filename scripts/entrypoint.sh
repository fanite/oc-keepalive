#!/bin/sh

echo -e "${LOOKBUSY_SCHEDULE}\t/bin/sh -ec timeout -k 0 ${BUSY_TIME} /script/lookbusy.sh 2>&1 &">/var/spool/cron/crontabs/root

echo -e "${SPEEDTEST_SCHEDULE}\t/bin/sh -ec /bin/sh -ec /script/speedtest.sh 2>&1 &">>/var/spool/cron/crontabs/root

echo "Scheduled task created successfully"

cat /var/spool/cron/crontabs/root