#!/bin/bash

echo "Is this a fresh VM?"
echo "Check the boot log.."
grep -h 'Command line: BOOT' /var/log/messages* | cut -c 1-12 | grep -v Jun| sort -M

