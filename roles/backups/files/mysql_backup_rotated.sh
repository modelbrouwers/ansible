#!/bin/bash

###########################
####### LOAD CONFIG #######
###########################

SCRIPTPATH=$(cd ${0%/*} && pwd -P)
source $SCRIPTPATH/mysql_backup.config


###########################
#### PRE-BACKUP CHECKS ####
###########################

# Make sure we're running as the required backup user
if [ $BACKUP_USER != "" -a "$(id -un)" != "$BACKUP_USER" ]; then
    echo "This script must be run as $BACKUP_USER. Exiting."
    exit 1;
fi;


###########################
### INITIALISE DEFAULTS ###
###########################

if [ ! $HOSTNAME ]; then
    HOSTNAME=""
fi;

if [ ! $USERNAME ]; then
    USERNAME="root"
fi;


###########################
#### START THE BACKUPS ####
###########################

function perform_backups()
{
    SUFFIX=$1
    FINAL_BACKUP_DIR=$BACKUP_DIR"`date +\%Y-\%m-\%d`$SUFFIX/"

    echo "Making backup directory in $FINAL_BACKUP_DIR"

    if ! mkdir -p $FINAL_BACKUP_DIR; then
        echo "Cannot create backup directory in $FINAL_BACKUP_DIR. Go and fix it!"
        exit 1;
    fi;

    ###########################
    ###### FULL BACKUPS #######
    ###########################

    FULL_BACKUP_QUERY="show databases like '%$PREFIX%'"

    echo -e "\n\nPerforming full backups"
    echo -e "--------------------------------------------\n"

    for DATABASE in `mysql --user="$USERNAME" --password="$PASSWORD" -Bse "$FULL_BACKUP_QUERY"`
    do
        echo -e "\nBacking up $DATABASE"

        if ! mysqldump $DATABASE --user="$USERNAME" --password="$PASSWORD" | gzip > $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress; then
            echo "[!!ERROR!!] Failed to produce plain backup database $DATABASE"
        else
            mv $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress $FINAL_BACKUP_DIR"$DATABASE".sql.gz
        fi

    done

    echo -e "\nAll database backups complete!"
}

# MONTHLY BACKUPS

DAY_OF_MONTH=`date +%d`

if [ $DAY_OF_MONTH = "1" ];
then
    # Delete all expired monthly directories
    find $BACKUP_DIR -maxdepth 1 -name "*-monthly" -exec rm -rf '{}' ';'

    perform_backups "-monthly"

    exit 0;
fi

# WEEKLY BACKUPS

DAY_OF_WEEK=`date +%u` #1-7 (Monday-Sunday)
EXPIRED_DAYS=`expr $((($WEEKS_TO_KEEP * 7) + 1))`

if [ $DAY_OF_WEEK = $DAY_OF_WEEK_TO_KEEP ];
then
    # Delete all expired weekly directories
    find $BACKUP_DIR -maxdepth 1 -mtime +$EXPIRED_DAYS -name "*-weekly" -exec rm -rf '{}' ';'

    perform_backups "-weekly"

    exit 0;
fi

# DAILY BACKUPS

# Delete daily backups 7 days old or more
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*-daily" -exec rm -rf '{}' ';'

perform_backups "-daily"
