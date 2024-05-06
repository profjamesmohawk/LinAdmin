#!/bin/bash

####################################################################
# Report the IP address seen by the outside world.
# In our case, it will be the address of the host interface used for
# NAT.
#
# Depdencies:
#	- curl
#	- what_is_my_ip.php (hosted on csunix)
#
# James Long, Summer 2024
####################################################################

WHAT_IS_MY_IP_URL="https://csunix.mohawkcollege.ca/~long/php/what_is_my_ip.php"

#######  no config changes required past this point ###############

curl -s $WHAT_IS_MY_IP_URL  | grep client

