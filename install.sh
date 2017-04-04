 #!/bin/bash

sudo ln -s ./milquetoast.sh /usr/local/bin/milquetoast

sudo usermod -g backup thorsten


sudo mkdir /etc/backup.d
sudo touch /etc/backup.d/000-example.bash
sudo echo "#!/bin/bash" >> /etc/backup.d/000-example.bash
sudo echo "PREPFOLDER=$1" >> /etc/backup.d/000-example.bash

sudo mkdir /var/backups/milquetoast
sudo mkdir /var/backups/milquetoast/backups
sudo mkdir /var/backups/milquetoast/preparation


sudo chown -R backup:backup /etc/backup.d
sudo chown -R backup:backup /var/backups/milquetoast

