#!/bin/bash

set -x


GW_USER=test
EXPERIMENT=123
FOLDERS=(consumption radio event sniffer log)
WORKDIR=/iotlab/users/${GW_USER}/.iot-lab/${EXPERIMENT}
DOCKER_IMAGE=isen/iot-lab-gateway:v1

dev_id=$1

echo "Starting gw $dev_id"
base_ip=20

CONTAINER_NAME=iot-lab-isen-$dev_id
CONTAINER_IP=192.168.0.$((base_ip + $dev_id))

device_id=/dev/ttyACM$dev_id


docker run --rm --name=$CONTAINER_NAME  --net=gw_net --ip=$CONTAINER_IP  \
   --device $device_id:/dev/iotlab/ttyON_STLINK  \
   --device /dev/bus/usb/001/004:/dev/bus/usb/001/004 \
   -v /tmp/cfg_dir/$dev_id:/var/local/config \
   -v $(pwd)/gateway_code/static:/shared/gateway_code/static \
   -v /tmp/exp_dir/$dev_id:${WORKDIR} \
   --env OCD_CONF_ID=$dev_id -d ${DOCKER_IMAGE}

sleep 5 

docker logs $CONTAINER_NAME
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME

