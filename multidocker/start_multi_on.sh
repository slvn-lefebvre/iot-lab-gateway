#!/bin/bash

set -x


CONFIG_ROOT=/tmp/cfg_dir

#cp -R $(pwd)/tests_utils/cfg_dir/ $cfg_dir
	


GW_USER=test
EXPERIMENT=123
FOLDERS=(consumption radio event sniffer log)

WORKDIR=/iotlab/users/${GW_USER}/.iot-lab/${EXPERIMENT}
	

DOCKER_IMAGE=isen/iot-lab-gateway:v1
DEVLIST=()

function detect_stlrwan() {
    readarray -t DEVLIST < <(printf 'stlrwan %s %s\n' $(lsusb -vv -t | grep -A1 ST-LINK/V2.1 | sort | uniq | grep /dev/bus))
}


function start_container_stlrwan() {
        ctr_id=$1
        CONTAINER_NAME=iot-lab-isen-$ctr_id
        ctr_ip=$2
        ctr_dev="${@:3}"
        ctr_dev_dir=$(echo ${ctr_dev[@]} | cut -d" " -f2)
        ctr_usb_dev=$(echo ${ctr_dev[@]} | cut -d" " -f3)
        ctr_tty_dir=$(find ${ctr_dev_dir}/* -type d -name ttyACM*)
        ctr_tty_id=$(basename $ctr_tty_dir)
        cfg_dir=$CONFIG_ROOT/$ctr_id
        mkdir -p $cfg_dir # check existence
        BOARD="st_lrwan1"
        CONTROL_NODE_TYPE="no"
        #echo "st_lrwan1" > $cfg_dir/board_type
        echo ${BOARD} > $cfg_dir/board_type
        echo ${CONTROL_NODE_TYPE} > $cfg_dir/control_node_type
        echo ${CONTAINER_NAME} > $cfg_dir/hostname
        
        docker run --rm --name=$CONTAINER_NAME --net=gw_net -h $CONTAINER_NAME --ip=$ctr_ip  \
           --device /dev/$ctr_tty_id:/dev/iotlab/ttyON_STLINK  \
           --device $ctr_usb_dev:$ctr_usb_dev \
            -v  $cfg_dir:/var/local/config \
            -v $(pwd)/gateway_code/static:/shared/gateway_code/static \
            -v /tmp/exp_dir/$dev_id:${WORKDIR} \
             -d ${DOCKER_IMAGE}
        #   --env OCD_CONF_ID=$dev_id
        
        sleep 5

        docker logs $CONTAINER_NAME
        docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME
}

dev_id=0
base_ip=20

# Device detection 
detect_stlrwan

for i in "${DEVLIST[@]}"; do
        echo "### Starting gw $dev_id ###"
        mkdir -p /tmp/exp_dir/$dev_id;

        for f in ${FOLDERS[@]}
        do 
            mkdir /tmp/exp_dir/$dev_id/$f 
        done

        CONTAINER_IP=192.168.0.$((base_ip + $dev_id))
        start_container_stlrwan $dev_id $CONTAINER_IP "$i"
        dev_id=$(($dev_id+1))
done
