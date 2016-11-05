#!/bin/bash

USER=$1
HOST=$2
BASE=/home/modelbrouw/backup
DEST=/tmp

day=$3

download_django() {
    backup_file=modelbrouwers.custom
    scp $USER@$HOST:$BASE/postgres/$day-daily/$backup_file $DEST/$backup_file
}

download_forum() {
    backup_file=modelbrouw_fora.sql.gz
    scp $USER@$HOST:$BASE/mysql/$day-daily/$backup_file $DEST/$backup_file
}

download_shop() {
    backup_file=modelbrouw_winkl.sql.gz
    scp $USER@$HOST:$BASE/mysql/$day-daily/$backup_file $DEST/$backup_file
}

download_kitreviews() {
    backup_file=modelbrouw_winkl.sql.gz
    scp $USER@$HOST:$BASE/mysql/$day-daily/$backup_file $DEST/$backup_file
}

download() {
    download_django
    download_forum
    download_shop
    download_kitreviews
}

download $3
