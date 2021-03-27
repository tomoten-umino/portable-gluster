FROM gluster/gluster-centos:gluster3u10_centos7

COPY ./volume /tmp/volume
COPY ./script /tmp/script
COPY ./.env /.env

RUN systemctl disable glusterd.service; systemctl disable gluster-setup.service; \
mkdir -p /home/gluster; \
mv /tmp/volume/gluster-server-1 /home/gluster/; mv /tmp/volume/gluster-server-2 /home/gluster/; \
mkdir -p /home/HDD1; \
mv /tmp/script/entry-point.service /etc/systemd/system/; \
systemctl enable entry-point.service; \
mv /tmp/script/entry-point.sh /entry-point.sh; \
rm -rf /tmp/*
