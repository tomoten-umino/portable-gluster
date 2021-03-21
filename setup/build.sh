#!/bin/bash

# Program name
PROGNAME=$(basename $0)

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
        if [ $prev_option != "-t" ]; then
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
  echo "-- build.sh ran --------------------------------------------"
  return 0
}

# check options
list "$@"

# main
main

exit 0

