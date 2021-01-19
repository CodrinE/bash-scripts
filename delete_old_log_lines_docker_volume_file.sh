#!/bin/ash
############################################################
# This script searches in a docker volume if a file exists #
# and deletes logs older than 3 days                       #
# log format: 2021-01-18 20:41:14                          #
############################################################

##docker image to search for
DOCKER_IMAGE=

##path to file inside the volume
PATH=

CONTAINER_ID=$(docker ps | grep $DOCKER_IMAGE | awk 'NR {print $1}')

VOLUME_PATH=$(docker inspect -f '{{ .Mounts }}' $CONTAINER_ID | grep -o '[^ ]*_data')

for volume in $VOLUME_PATH
do
        file_path="${volume}${PATH}"
        if [ -f $file_path ]; then
                sed -i -e/$(date -d "3 days ago" "+%F")/\{ -e:1 -en\;b1 -e\} -ed $file_path
        fi
done
