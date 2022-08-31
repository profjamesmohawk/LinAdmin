#!/bin/bash

#
# wget command to fetch all of the content for COMP-10018
# to the local file system.
#
# This is only useful because all of the content is static
#
# James Long
# Fall 2020
#

wget	\
     --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --domains csunix.mohawkcollege.ca \
     --no-parent \
     https://csunix.mohawkcollege.ca/~long/courses/comp-10018/content/
