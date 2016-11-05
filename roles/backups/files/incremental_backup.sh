#!/bin/bash

#
# Adapted from http://webgnuru.com/linux/rsync_incremental.php
#
TARGET_BASE=''
DAYS_BETWEEN_FULL=30  # number of days between full backups.
RSYNC_OPTS="-rvLtShP"

today=`date -I`
prev_day=$today  # check if backup from today exists


# helper function to get the absolute path to the target directory
get_target() {
    root_dir=$TARGET_BASE$1
    if [[ $2 ]]; then
        root_dir=$root_dir/$2
    fi
    echo $root_dir
}


LOG=`get_target $today 'rsync_inc.log'`

# do the date calculations
# determine if a full/incremental backup should be taken
run_backup() {
    label=$1
    src=$2
    TARGET_BASE=$3

    echo -e "\e[1mRunning \"$label\" file backups\e[21m...\n"

    backup_from_today=`get_target $today`
    if [ -d $backup_from_today ]; then
        echo "backup for $today was already created, aborting"
        exit 0
    fi

    # now check for past backups (incremental based on that)
    echo "Checking for old backups..."
    i=0
    prev_backup=backup_from_today  # initially, does not exist
    while [ $i -lt 100 ] && [ ! -d $prev_backup ]
    do
        i=$[i+1]
        prev_day=`date -I -d "$i day ago"`
        prev_backup=`get_target $prev_day`
    done

    echo "> at least $i days since last backup"

    target=`get_target $today`
    temp_target="$target.inprogress"
    echo -e "\nCreating temporary target directory $temp_target"
    mkdir -p $temp_target

    # check if we need a new full backup
    j=1
    need_full_backup=true
    prev_date=`date -I -d "1 day ago"`
    prev=`get_target $prev_date`  # initially, does not exist
    while [ $j -lt $[DAYS_BETWEEN_FULL+2] ] && [ "$need_full_backup" = true ]
    do
        if [ -f $prev/rsync_full.log ]; then
            need_full_backup=false
        fi
        j=$[j+1]
        local prev_date=`date -I -d "$j day ago"`
        prev=`get_target $prev_date`
    done

    if [ $i -lt $DAYS_BETWEEN_FULL ] && [ "$need_full_backup" = false ]; then
        echo -e "creating incremental backup, based on" $prev_day "\n"
        incremental_backup $src $temp_target $prev_day
    else
        echo -e "creating full backup \n"
        full_backup $src $temp_target
    fi

    if [ $? -eq 1 ]; then
        echo -e "\e[1m\e[31mBackup failed, aborting.\e[0m"
        exit 1
    fi

    mv $temp_target $target
    echo -e "\e[32mBackup completed.\e[0m"
}


incremental_backup() {
    local src=$1
    local dest=$2
    comp=`get_target $prev_day/`
    log=$dest/rsync_inc.log
    rsync $RSYNC_OPTS --link-dest=$comp $src $dest > $log
}


full_backup() {
    local src=$1
    local dest=$2
    log=$dest/rsync_full.log
    rsync $RSYNC_OPTS $src $dest > $log
}
