#!/bin/bash

source /.env

# peer setting
gluster peer probe $HOSTNAME_2
sleep 1

# create volume
gluster volume create $VOLUME_NAME replica 2 $HOSTNAME_1:/home/HDD1 $HOSTNAME_2:/home/HDD1 force
sleep 1

# start gluster volume
gluster volume start $VOLUME_NAME
sleep 1


