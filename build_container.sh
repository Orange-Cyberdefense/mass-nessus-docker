#!/bin/bash
# Creates container using inputs
# Inputs: $login $password $port $licence
# EX: lille securepass 8832 AA-BB-CC

# vars
LOGIN=$1
PASSWORD=$2
LOCAL_PORT=$3
LICENCE=$4
DOCKER_NAME=nessus_docker_container_$LOGIN

# detect if already existing container
EXISTING_CONTAINER=$(docker ps -a --filter "name=$DOCKER_NAME" -q)
if [ ! -z $EXISTING_CONTAINER ]
then
	echo "Existing container found, removing it"

	echo "[+] Backing up existing data in tmp_$EXISTING_CONTAINER"
	mkdir tmp_$EXISTING_CONTAINER # Backup
	docker exec -i $EXISTING_CONTAINER /opt/nessus/sbin/nessuscli backup --create backup_nessus.bak
	docker cp $EXISTING_CONTAINER:/opt/nessus/var/nessus/backup_nessus.bak tmp_$EXISTING_CONTAINER
	echo "-> Backup done"

	docker stop $EXISTING_CONTAINER # destroyyyyy
	docker rm $EXISTING_CONTAINER
fi

# run docker
echo "Creating container.."
docker run -d -p 127.0.0.1:$LOCAL_PORT:8834 --name $DOCKER_NAME \
 -v $(pwd)/nessus_data_$LOGIN/users:/opt/nessus/var/nessus/users \
 nessus_docker_image:latest
DOCKER_UID=$(docker ps --filter "name=$DOCKER_NAME" -q)
echo "[+] Docker created under name $DOCKER_NAME, UID $DOCKER_UID"


# detects if Nessus is compiling plugins, based on web app
echo "Compiling plugins (may take a while).."
code="503"
while [[ $code == "503" ]]
do
	sleep 30
	req=$(docker exec -i $DOCKER_UID curl https://127.0.0.1:8834/server/status --insecure -s)
	code=$(echo $req | cut -d "," -f 1 | cut -d ":" -f 2)
	status=$(echo $req | cut -d "," -f 3 | cut -d ":" -f 2 | cut -d "\"" -f 2)
	if [ "$status" = "register" ]
	then
		code="200" # ./build_container.sh: ligne 48: break﻿﻿ : commande introuvable
		break﻿﻿
	fi
done
echo "[+] Compilation done"

# reput user/scan files in the container
if [ -d tmp_$EXISTING_CONTAINER ]
then
	echo "Importing data from previous container"
	docker cp tmp_$EXISTING_CONTAINER/backup_nessus.bak $DOCKER_UID:/tmp/
	docker exec -i $DOCKER_UID /etc/init.d/nessusd stop
	docker exec -i $DOCKER_UID /opt/nessus/sbin/nessuscli backup --restore /tmp/backup_nessus.bak

	rm tmp_$EXISTING_CONTAINER/*
	rmdir tmp_$EXISTING_CONTAINER
fi


# nessus register
echo "Registering Nessus under licence $LICENCE.."
docker exec -i $DOCKER_UID /etc/init.d/nessusd stop
docker exec -i $DOCKER_UID /opt/nessus/sbin/nessuscli fetch --register $LICENCE
docker exec -i $DOCKER_UID /etc/init.d/nessusd start

# creating account
docker exec -i $DOCKER_UID /root/create_nessus_user.sh $LOGIN $PASSWORD
docker exec -i $DOCKER_UID sed -i "s/CHUSERNAME/$LOGIN/g" /root/nessus_clean_old_scans.sh
docker exec -i $DOCKER_UID sed -i "s/CHPASSWORD/$PASSWORD/g" /root/nessus_clean_old_scans.sh
echo "[+] Nessus is available on https://127.0.0.1:$LOCAL_PORT as $LOGIN / $PASSWORD"
