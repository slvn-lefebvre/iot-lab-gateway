# -*- coding:utf-8 -*-

# This file is a part of IoT-LAB gateway_code
# Copyright (C) 2015 INRIA (Contact: admin@iot-lab.info)
# Contributor(s) : see AUTHORS file
#
# This software is governed by the CeCILL license under French law
# and abiding by the rules of distribution of free software.  You can  use,
# modify and/ or redistribute the software under the terms of the CeCILL
# license as circulated by CEA, CNRS and INRIA at the following URL
# http://www.cecill.info.
#
# As a counterpart to the access to the source code and  rights to copy,
# modify and redistribute granted by the license, users are provided only
# with a limited warranty  and the software's author,  the holder of the
# economic rights,  and the successive licensors  have only  limited
# liability.
#
# The fact that you are presently reading this means that you have had
# knowledge of the CeCILL license and that you accept its terms.

""" Open Node STM32 LRWAN1 ISEN experiment implementation """

from gateway_code.config import static_path
from gateway_code.open_nodes.node_st_lrwan1 import NodeStLrwan1
import os 

STATIC_SHARED_DIR="/shared/gateway_code/static/"

def shared_path(fname):
    return os.path.join(STATIC_SHARED_DIR,fname)

class NodeStLrwan1Isen(NodeStLrwan1):
    """ Open node STM32 LRWAN1 implementation """
    dev_id = os.getenv("OCD_CONF_ID")
    conf_name = 'iot-lab-st-lrwan1.cfg'

    if dev_id is not None: 
        conf_name = "iot-lab-st-lrwan1-{}.cfg".format(dev_id)

    TYPE = 'st_lrwan1_isen'
    OPENOCD_CFG_FILE = shared_path(conf_name)
    