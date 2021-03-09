#!/bin/bash
# Builds the image

echo "Building base image.."

# Removing actually running container based on the image
RUNNING_CONTAINER=$(docker ps -a --filter "name=nessus_docker_container" -q)
if [ ! -z $RUNNING_CONTAINER ]
then
	echo "Running container(s) found, removing it"
	for i in $RUNNING_CONTAINER
	do
		docker stop $i
		docker rm $i
	done
fi

# Removing previous image
EXISTING_ID=$(docker images nessus_docker_image --format "{{.ID}}")
if [ ! -z $EXISTING_ID ]
then
	docker image rm -f $EXISTING_ID # remove the RUNNING one
fi

docker build . -t nessus_docker_image:latest
