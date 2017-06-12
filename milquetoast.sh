#!/bin/bash
 
## config
set +o allexport
#MT_MAIN_NAME=<HOSTNAME>		
#MT_RCLONE_CONF=<PATH_TO_RCLONE.CONF>		
#MT_RCLONE_TARGET=<CLOUDTYPE>:<SOME_PATH>/$MT_MAIN_NAME		
#MT_BACKUPS=<SOME_PATH>		
#MT_BACKUP_PREPS=<SOME_PATH>		
#MT_BACKUPD=<PATH_TO_BACKUP.D_DIR>
. /etc/milquetoast.conf
set -o allexport

TODAY=$(date +"%Y%m%d")
echo
echo "-------------------------------------------------------------"
echo "-- Milquetoast ... No backup no pitty "
echo "-------------------------------------------------------------"
echo
echo "... doing the work for $TODAY"
echo

echo "* cleanup"

if [ ! -z "$MT_BACKUP_PREPS" ]; then
    rm "$MT_BACKUP_PREPS/*"
fi

#execute simple backup scripts
echo "* executing backup steps:"
cd $MT_BACKUPD
for backupstep in $(ls -1 [0-9+]* 2> /dev/null)
    do
        echo "  -> $backupstep"
        $MT_BACKUPD/$backupstep $MT_BACKUP_PREPS $TODAY 
done

#create a single backup file for today
echo "* creating single backup file for today"
cd $MT_BACKUP_PREPS
tar -zcPf $MT_BACKUPS/$TODAY.$MT_MAIN_NAME.tar.gz ./$TODAY*

#delete old backups
ROTATE_DELETE_OPTIONS="--daily=10 --weekly=5 --monthly=13 --yearly=5"
echo "* executing rotate-delete $ROTATE_DELETE_OPTIONS $MT_BACKUPS"
docker run -t --rm -v $MT_BACKUPS:/data cismet/rotated-delete $ROTATE_DELETE_OPTIONS

#externalize
echo "* externalize"

docker run -t --rm \
  -e PUID=$(id -u backup) \
  -e PGID=$(id -g backup) \
  -v $MT_RCLONE_CONF:/home/.rclone.conf \
  -v $MT_BACKUPS:/data \
  farmcoolcow/rclone \
    sync /data gdrive:/cismet/backups/$MT_MAIN_NAME

echo
echo "------------------------------------------------------- done."
