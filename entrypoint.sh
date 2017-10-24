#!/bin/bash

CRONTAB_FILE=/opt/backup/crontab
CRON_SCRIPTS=/opt/backup/scripts/*

if [ -z "$SCHEDULE" ]; then
  export SCHEDULE='@daily'
fi

touch $CRONTAB_FILE

for SCRIPT in $CRON_SCRIPTS
do
  echo "Creating cron entry for $SCRIPT"
  echo "$SCHEDULE $SCRIPT" >> $CRONTAB_FILE
done

exec "$@"