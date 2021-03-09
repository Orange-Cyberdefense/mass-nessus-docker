#!/bin/bash
# Builds all the containers using the input file container_details.csv

CONTAINER_DETAILS="container_details.csv"

if [ ! -f "./$CONTAINER_DETAILS" ]
then
  echo "File $CONTAINER_DETAILS does not exist"
  exit 0
fi


for i in $(tail -n +2 $CONTAINER_DETAILS) # do not read first line
do
  login=$(echo $i | cut -d ";" -f 1)
  password=$(echo $i | cut -d ";" -f 2)
  port=$(echo $i | cut -d ";" -f 3)
  licence=$(echo $i | cut -d ";" -f 4)

  echo "Building container $1"
  ./build_container.sh $login $password $port $licence
done
