#!/bin/bash

if [ ! -d ${DATA_VOLUME_WWWW}/owncloud ]; then
	mv /tmp/owncloud ${DATA_VOLUME_WWWW}/
fi

# replace default template apache
cp -f /tmp/owncloud.conf /etc/apache2/templates/default.confsite

# Remove html folder
rm -Rf ${DATA_VOLUME_WWWW}/html

# Install or upgrade
chown -R www-data:www-data ${DATA_VOLUME_WWWW}/owncloud/
cd ${DATA_VOLUME_WWWW}/owncloud/

installed="$(sudo -u www-data php occ status | grep "installed: true")"
if [ $installed = "" ]; then
	MYSQL_CREDENTIALS=$(head -n 1 ${DATA_VOLUME_WWWW}/backup/mysql/credentials)
	IFS=':' read -r -a MYSQL_CREDENTIALS <<< "$ROOT_CREDENTIALS"
	sudo -u www-data php occ  maintenance:install --database "${WORKER_NAME}" --database-name "${WORKER_NAME}"  \
		--database-user "${ROOT_CREDENTIALS[0]}" --database-pass "${ROOT_CREDENTIALS[1]}" --admin-user "admin" --admin-pass "${ROOT_CREDENTIALS[1]}"
else
	sudo -u www-data php occ repair
	sudo -u www-data php occ upgrade
fi

# Strong permissions
ocpath="${DATA_VOLUME_WWWW}/owncloud"
htuser='www-data'
htgroup='www-data'
rootuser='root'

find ${ocpath}/ -type f -print0 | xargs -0 chmod 0640
find ${ocpath}/ -type d -print0 | xargs -0 chmod 0750

chown -R ${rootuser}:${htgroup} ${ocpath}/
chown -R ${htuser}:${htgroup} ${ocpath}/apps/
chown -R ${htuser}:${htgroup} ${ocpath}/config/
chown -R ${htuser}:${htgroup} ${ocpath}/data/
chown -R ${htuser}:${htgroup} ${ocpath}/themes/

chown ${rootuser}:${htgroup} ${ocpath}/.htaccess
chown ${rootuser}:${htgroup} ${ocpath}/data/.htaccess

chmod 0644 ${ocpath}/.htaccess
chmod 0644 ${ocpath}/data/.htaccess
