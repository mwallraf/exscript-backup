## Docker entrypoint to create the crontab scheduler

#!/bin/bash

# Start the run once job.
echo "Docker container has been started"

# Setup a cron schedule - kill when running longer than 23h
echo "0 10 * * * cd /opt/exscript-backup && timeout 82800 /bin/bash exscript-backup.sh backup >> /var/log/cron.log 2>&1
30 23 * * * cd /opt/exscript-backup && /bin/bash exscript-backup.sh archive >> /var/log/cron.log 2>&1
*/5 * * * * cd /opt/exscript-backup && /bin/bash exscript-backup.sh purge >> /var/log/cron.log 2>&1
# This extra line makes it a valid cron" > scheduler.txt

crontab scheduler.txt
crond -f

