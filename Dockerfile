FROM soletic/phpserver
MAINTAINER Sol&TIC <serveur@soletic.org>

RUN apt-get update && \
  apt-get -y install php5-imagick wget

RUN cd /tmp && wget https://download.owncloud.org/community/owncloud-8.2.1.zip && \
	unzip owncloud-8.2.1.zip

ADD start-owncloud.sh /root/scripts/start-owncloud.sh
ADD supervisord-owncloud.conf /etc/supervisor/conf.d/supervisord-owncloud.conf
ADD owncloud.conf /tmp/owncloud.conf

# MAKE SCRIPT EXCUTABLE
RUN chmod 755 /root/scripts/*.sh