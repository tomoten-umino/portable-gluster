#!/bin/bash

# import my-env file
source ./.env
# Program name
PROGNAME=$(basename $0)
# working directory
NOW_DIR=`pwd`
# deploy directory
DEPLOY_DIR="../deploy"
# option : docker image name
IMAGE_NAME=""

function usage() {
  cat <<_EOT_

Usage:
  ./$PROGNAME [OPTIONS]

Description:
  Build my gluster image using docker

Options:
  -t, --tag list    Name and optionally a tag in the 'name:tag' format

_EOT_
  exit 1
}

function list() {
  local param+=( "$@" )
  local prev_option="aaa"
  for OPT in "$@"
  do
    case $OPT in
      -h | --help)
        usage
        exit 1
        ;;
      -t | --tag)
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "$PROGNAME: option requires an argument -- $1" 1>&2
          usage
          exit 1
        fi
        IMAGE_NAME=$2
        prev_option=$1
        shift 2
        ;;
      -- | -)
        shift 1
        param+=( "$@" )
        break
        ;;
      -*)
        echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
        usage
        exit 1
        ;;
      *)
        if [ $prev_option != "-t" ] && [ $prev_option != "--tag" ]; then
          echo "$PROGNAME: illegal option or param -- '$(echo $1 | sed 's/^-*//')'" 1>&2
          usage
          exit 1
        fi
        prev_option=$1
        ;;
      esac
  done

  if [ -z "$param" ]; then
      echo "$PROGNAME: too few arguments" 1>&2
      usage
      exit 1
  fi
}


function main() {
  echo "-- build.sh run --------------------------------------------"
  # start gluster containers
  echo "-- 1. start gluster containers -----------------------------"
  docker-compose up -d
  sleep 10

  echo ""; echo ""
  # setup gluster volume
  echo "-- 2. setup gluster volume ---------------------------------"
  echo 'docker-compose exec -d gluster-server-1 /setup.sh'
  docker-compose exec -d gluster-server-1 /setup.sh
  sleep 10

  echo ""; echo ""
  # stop and delete gluster containers
  echo "-- 3. stop and delete gluster containers -------------------"
  docker-compose down
  sleep 10

  echo ""; echo ""
  # build docker image
  echo "-- 4. build docker image -----------------------------------"
  sudo docker image build -t $IMAGE_NAME .

  echo ""; echo ""
  # write docker-compose.yml for deployment
  echo "-- 5. write docker-compose.yml for deployment  -------------"
  
  export HOSTNAME_1=${HOSTNAME_1}
  export HOSTNAME_2=${HOSTNAME_2}
  export IP_ADDR_1=${IP_ADDR_1}
  export IP_ADDR_2=${IP_ADDR_1}
  export IMAGE_NAME=${IMAGE_NAME}
  envsubst '$HOSTNAME_1' < docker-compose.yml.deploy |
  envsubst '$HOSTNAME_2' |
  envsubst '$IP_ADDR_1' |
  envsubst '$IP_ADDR_2' |
  envsubst '$IMAGE_NAME' > docker-compose.yml.deploy.tmp

  mv docker-compose.yml.deploy.tmp ../deploy/docker-compose.yml  

  echo ""; echo ""
  # write docker image for deployment
  echo "-- 6. write docker image for deployment  -------------"
  docker image save -o ../deploy/portable-gluster.tar $IMAGE_NAME

  echo ""; echo ""
  echo "-- build.sh ran --------------------------------------------"
  return 0
}

# check options
list "$@"

# main
main

exit 0

