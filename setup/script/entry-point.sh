#!/bin/bash

source .env

# DEFINE
TRUE="0"
FALSE="1"
FLAG_OFF="0"
FLAG_ON="1"

function main() {
  echo "entry-point start." > /tmp/start.log

  # delete default gluster setting
  rm -rf /etc/glusterfs
  rm -rf /var/lib/glusterd

  local ret=$FALSE
  local gluster=""

  # gluster-server-1 setting
  echo $HOSTNAME | grep $HOSTNAME_1 >/dev/null 2>&1
  ret=$?
  if [ $ret = $TRUE ]; then
    gluster="gluster-server-1"
  fi

  # gluster-server-2 setting
  echo $HOSTNAME | grep $HOSTNAME_2 >/dev/null 2>&1
  ret=$?
  if [ $ret = $TRUE ]; then
    gluster="gluster-server-2"
  fi

  if [ x$gluster = "x" ]; then
    echo "mismach hostname." > /tmp/start.log
    return $FALSE
  fi

  # move gluster setting
  mv /home/gluster/$gluster/etc-glusterfs /etc/glusterfs
  mv /home/gluster/$gluster/var-lib-glusterd /var/lib/glusterd

  local init_flag=$FLAG_OFF
  if [ -d /home/HDD1/.glusterfs ]; then
    echo "exist /home/HDD1/.glusterfs" >>/tmp/start.log
  else
    echo "no exist /home/HDD1/.glusterfs" >>/tmp/start.log
    echo "mv /home/gluster/$gluster/HDD1/.glusterfs /home/HDD1/" >>/tmp/start.log
    mv /home/gluster/$gluster/HDD1/.glusterfs /home/HDD1/
    init_flag=$FLAG_ON
  fi


  sleep 1

  # starting glusterd
  systemctl restart glusterd

  if [ $init_flag != $FLAG_OFF ]; then
    sleep 10
    # gluster force-restart
    echo "gluster vol start VOL1 force" >>/tmp/start.log
    gluster vol start VOL1 force
  fi

  echo "entry-point started." >>/tmp/start.log
  return $TRUE
}

main

if [ $? != $TRUE ]; then
  exit $FALSE
else
  exit $TRUE
fi
