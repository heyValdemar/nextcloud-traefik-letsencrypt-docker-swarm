#!/bin/bash

NEXTCLOUD_BACKUPS_CONTAINER=$(docker ps -aqf "name=nextcloud_backups")

echo "--> All available application data backups:"

for entry in $(docker container exec -it $NEXTCLOUD_BACKUPS_CONTAINER sh -c "ls /srv/nextcloud-application-data/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore application data and press [ENTER]
--> Example: nextcloud-application-data-backup-YYYY-MM-DD_hh-mm.tar.gz"
echo -n "--> "

read SELECTED_APPLICATION_BACKUP

echo "--> $SELECTED_APPLICATION_BACKUP was selected"

echo "--> Scaling service down..."
docker service scale nextcloud_nextcloud=0

echo "--> Restoring application data..."
docker exec -it $NEXTCLOUD_BACKUPS_CONTAINER sh -c "rm -rf /var/atlassian/application-data/nextcloud/* && tar -zxpf /srv/nextcloud-application-data/backups/$SELECTED_APPLICATION_BACKUP -C /"
echo "--> Application data recovery completed..."

echo "--> Scaling service up..."
docker service scale nextcloud_nextcloud=1
