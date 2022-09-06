#! /bin/bash -x

# start an experiment (id 123, user named test), with the given firmware, with no monitoring
# example:
#  ./start_exp_fw.sh <path-to-firmware.elf>


ip=$1

curl -X POST -H "Content-Type: multipart/form-data" http://$ip:8080/exp/start/123/test \
    -F "firmware=@$2"; echo
