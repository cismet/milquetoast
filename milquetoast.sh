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

# removing previous preperation files
echo "* cleanup"
if [ ! -z "$MT_BACKUP_PREPS" ]; then
    for prep in $MT_BACKUP_PREPS/*; do
        echo "  -> deleting preparation file: $(basename $prep)"
        rm $prep
    done
fi

#backup backupstep-skripts
echo "* executing backup of the backup steps"
tar -cPf $MT_BACKUP_PREPS/$TODAY.milquetoast_backupd.tar \
  $MT_BACKUPD/[0-9+]*

#execute simple backup scripts
echo "* executing backup steps:"
for backupstep in $(ls -1 $MT_BACKUPD/[0-9+]* 2> /dev/null); do
    echo "  -> $(basename $backupstep)"
    $backupstep $MT_BACKUP_PREPS $TODAY 
done

#create a single backup file for today
echo "* creating single backup file for today"
cd $MT_BACKUP_PREPS
tar -zcPf $MT_BACKUPS/$TODAY.$MT_MAIN_NAME.tar.gz $TODAY*
cd -

#externalize
echo "* externalize"
cp --preserve=all $MT_RCLONE_CONF /tmp/milquetoast.rclone.conf
docker run -t --rm \
  -e PUID=$(id -u backup) \
  -e PGID=$(id -g backup) \
  -v /tmp/milquetoast.rclone.conf:/home/.rclone.conf \
  -v $MT_BACKUPS:/data \
  farmcoolcow/rclone \
    copy /data gdrive:/cismet/backups/$MT_MAIN_NAME

rm $MT_BACKUPS/$TODAY.$MT_MAIN_NAME.tar.gz

[ $? -eq 0 ] && {
  rm $MT_BACKUPS/$TODAY.$MT_MAIN_NAME.tar.gz
} || {
  echo "externalize failed. could not upload backup." 1>&2
}

echo
echo "------------------------------------------------------- done."

