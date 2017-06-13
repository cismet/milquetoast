#!/bin/bash

# environment variables

MT_CONF=/etc/milquetoast.conf
MT_ETC_DIR=/etc/milquetoast
MT_VAR_DIR=/var/backups/milquetoast

# I guess it is not the best way to have the users hardcoded.
# I comment this lines out because milquetoast works fine with "sudo milquetoast".
#sudo addgroup thorsten backup
#sudo addgroup docker backup
#sudo addgroup jruiz backup
#sudo addgroup therter backup
#sudo addgroup pdihe backup

# creating directories
sudo mkdir \
   $MT_ETC_DIR \
   $MT_ETC_DIR/backup.d \
   $MT_VAR_DIR \
   $MT_VAR_DIR/backups \
   $MT_VAR_DIR/preparation

#creating conf file
cat <<EOF | sudo tee -a $MT_CONF > /dev/null
MT_MAIN_NAME=$(hostname)
MT_RCLONE_CONF=$MT_ETC_DIR/rclone.conf
MT_RCLONE_TARGET=gdrive:/cismet/backups/\$MT_MAIN_NAME
MT_BACKUPS=$MT_VAR_DIR/backups
MT_BACKUP_PREPS=$MT_VAR_DIR/preparation
MT_BACKUPD=$MT_ETC_DIR/backup.d
EOF

# creating exemple file
cat <<EOF | sudo tee -a $MT_ETC_DIR/backup.d/000-example.sh > /dev/null
#!/bin/bash
PREPFOLDER=\$1
TODAY=\$(date +"%Y%m%d")
touch \$PREPFOLDER/\$TODAY.firstTest
EOF

# changing ownership
sudo chown -R backup:backup \
   $MT_ETC_DIR \
   $MT_VAR_DIR \
   $MT_CONF
   
# making milquetoast a system command
sudo ln -s $(pwd)/milquetoast.sh /usr/local/bin/milquetoast
