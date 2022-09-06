#!/bin/bash


# TODO put all this in a ansible file 

#  docker network  create -d ipvlan --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o ipvlan_mode=l2 -o parent=eth0 gw_net

set -x 

CONTROL_NODE_TYPE=no
BOARD=st_lrwan1_isen
HOST=0.0.0.0
start_tcp_port=8080
start_serial_port=20000
	
DOCKER_IMAGE=isen/iot-lab-gateway


sudo rm -rf /tmp/exp_dir; sudo rm -rf /tmp/cfg_dir

for i in $(find /dev  -iname "iotlab*")
do

	dev_id=$(echo $i | tr -dc '0-9') #extract device id from the /dev/ symlink path 

	mkdir -p /tmp/cfg_dir/$dev_id
	cfg_dir=/tmp/cfg_dir/$dev_id
	cp -R $(pwd)/tests_utils/cfg_dir/ $cfg_dir
	
	echo ${BOARD} > $cfg_dir/board_type
	echo ${CONTROL_NODE_TYPE} > $cfg_dir/control_node_type
	echo ${BOARD}-$dev_id > $cfg_dir/hostname

	GW_USER=test
	EXPERIMENT=123
	FOLDERS=(consumption radio event sniffer log)

	
	WORKDIR=/iotlab/users/${GW_USER}/.iot-lab/${EXPERIMENT}
	
	 mkdir -p /tmp/exp_dir/$dev_id;

	for f in ${FOLDERS[@]}
	do 
		 mkdir /tmp/exp_dir/$dev_id/$f 
	done

# Removed docker cn mapping because not running on 
# NO control nodes

done

# echo "Generate openocd configuration "

# dev_list=$(dmesg | grep ttyACM | cut -d"]" -f 2 | sort | uniq)
# INITIAL_CONF_PATH=$(pwd)/gateway_code/common/static/iot-lab-st-lrwan1.cfg


# for d in ${dev_list[@]}
# do
# 	usb_loc=$(echo $d | cut -d":" -f1 | cut -d" " -f2)
# 	dev_id=$(echo $d | cut -d":" -f3 | tr -dc '0-9')
# done

