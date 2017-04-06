 #!/bin/bash

sudo ln -s ./milquetoast.sh /usr/local/bin/milquetoast

sudo addgroup thorsten backup
sudo addgroup docker backup
sudo addgroup jruiz backup
sudo addgroup therter backup
sudo addgroup pdihe backup

sudo mkdir /etc/backup.d
sudo touch /etc/backup.d/000-example.bash

sudo mkdir /var/backups/milquetoast
sudo mkdir /var/backups/milquetoast/backups
sudo mkdir /var/backups/milquetoast/preparation


sudo chown -R backup:backup /etc/backup.d
sudo chown -R backup:backup /var/backups/milquetoast
sudo bash -c 'echo "#!/bin/bash" >> /etc/backup.d/000-example.sh'
sudo bash -c 'echo "PREPFOLDER=\$1" >> /etc/backup.d/000-example.sh'
sudo bash -c 'TODAY=\$(date +"%Y%m%d")'
sudo bash -c 'cd \$PREPFOLDER'
sudo bash -c 'touch \$TODAY.firstTest'

sudo chmod -R g+w /etc/backup.d/
sudo chmod -R g+w /var/backups/milquetoast
sudo chmod g+x /etc/backup.d/000-example.sh
