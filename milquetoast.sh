 #!/bin/bash
 
## config 
MT_MAIN_NAME=billy
MT_RCLONE_TARGET=gdrive:/cismet/backups/$MT_MAIN_NAME

MT_BACKUPS=/var/backups/milquetoast/backups
MT_BACKUP_PREPS=/var/backups/milquetoast/preparation
MT_BACKUPD=/etc/backup.d/
TODAY=$(date +"%Y%m%d")
echo
echo "-------------------------------------------------------------"
echo "-- Milquetoast ... No backup no pitty "
echo "-------------------------------------------------------------"
echo
echo '... doing the work for '$TODAY
echo
#delete prep folder
rm $MT_BACKUP_PREPS/*

#execute simple backup scripts
cd $MT_BACKUPD
for backupstep in $(ls -1 [0-9+]* 2> /dev/null)
    do
        $MT_BACKUPD/$backupstep $MT_BACKUP_PREPS $TODAY
done

#create a single backup file for today
cd $MT_BACKUP_PREPS
tar -zcvf $MT_BACKUPS/$TODAY.$MT_MAIN_NAME.tar.gz ./$TODAY*

#delete old backups
echo "rotate-backups --daily=10 --weekly=5 --monthly=13 --yearly=5 $MT_BACKUPS"

#externalize
echo "externalize ..."

docker run -t --rm \
  -e PUID=$(id -u $(whoami)) \
  -e PGID=$(id -g $(whoami)) \
  -v  /etc/backup.d/rclone.conf:/home/.rclone.conf \
  -v $MT_BACKUPS:/data \
  farmcoolcow/rclone \
    sync /data gdrive:/cismet/backups/$MT_MAIN_NAME
echo
echo "------------------------------------------------------- done."
