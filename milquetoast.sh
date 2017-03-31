 #!/bin/bash
 
## config 
MT_MAIN_NAME=leo
MT_RCLONE_TARGET=gdrive:/cismet/backups/$MT_MAIN_NAME

MT_BACKUPS=/var/backups/cismet
MT_BACKUP_PREPS=/var/backups/cismet_prep
MT_BACKUPD=/etc/backup.d/

## -------------------------------------------------------------

#delete prep folder
rm $MT_BACKUP_PREPS/$(date +"%Y%m%d")*

#execute simple backup scripts
cd $MT_BACKUPD
for backupstep in $(ls -1 [0-9+]* 2> /dev/null)
    do
        $MT_BACKUPD/$backupstep $MT_BACKUP_PREPS
done

#create a single backup file for today
cd $MT_BACKUP_PREPS
tar -zcvf $MT_BACKUPS/$(date +"%Y%m%d").$MT_MAIN_NAME.tar.gz ./$(date +"%Y%m%d")*

#delete old backups
rotate-backups --daily=10 --weekly=5 --monthly=13 --yearly=5 $MT_BACKUPS

#externalize
/usr/sbin/rclone sync $MT_BACKUPS gdrive:/cismet/backups/$MT_MAIN_NAME