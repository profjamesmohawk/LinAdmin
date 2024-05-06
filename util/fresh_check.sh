#!/bin/bash

####################################################################
# Report boot history since VM publish date
# Used by grading scripts to check for 'freshly imported' VM
#
# James Long, Summer 2024
####################################################################

PUBLISH_DATE="2024-04-16"

#######  no config changes required past this point ###############

journalctl --since=$PUBLISH_DATE | grep 'Command line:' | cut -c 1-12

