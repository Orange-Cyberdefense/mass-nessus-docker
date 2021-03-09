# Nessus-Docker
This project has been created prior Tenable published their version of [https://docs.tenable.com/nessus/Content/DeployNessusDocker.htm](dockerised Nessus).

As the new version of Nessus does not manage multiple users on the same instance, I created this project to deploy multiple instances of Nessus easily, each instance having its own user and its own licence.

## 1. Generate the template
`$ ./1-build_image.sh`

Depends on:
- Dockerfile
- get_latest_release.sh
- startup.sh
- create_nessus_user.sh
- nessus_clean_old_scans.sh

## 2. Populate container_details.csv
`$ nano ./container_details.csv`

After the line `login;password;port;licence`, add a new one on the same model.

No space, don't delete the first line, don't use ";" in the login/passwords.

For example : `user1;G00dPassword;8834;AA-BB-CC-DD`.

Add as many lines as containers needed.

## Optionnal: Delete results every X days
In my use case, I needed to be sure every result stored on the Nessus instances was deleted every two weeks.

To do so, edit the `Dockerfile` and uncomment the lines 16 to 21. The cron will be executed every day at 1am.

To change the data retention period, edit the line 18 in `nessus_clean_old_scans.sh`.

## 3. Build the container
`$ ./2-build_all_containers.sh`

The program will first compile plugins, then run through Nessus setup.

Wait for the `[+] Nessus is available on (...)` line to appear, it can take several minutes.

Once done, the containers are running.

Depends on:
- build_container.sh
- container_details.csv

## 4. Running the containers
You should have the built containers available using `$ docker ps -a | grep nessus`.

To run the containers, execute `$ docker start nessus_docker_container_[name]` for each container.

To check if the containers are running, execute `$ docker ps | grep nessus`. The status and ports are displayed.

## 5. Troubleshoots
### *docker: Error response from daemon: --storage-opt is supported only for overlay over xfs with 'pquota' mount option.*
The `storage-opt` option is used to create bigger volumes.

If its usage presents troubles, there are 2 solutions:
- remove the part `--storage-opt size=25G` from the `docker run` line in `build_container.sh` file
- add `GRUB_CMDLINE_LINUX_DEFAULT="rootflags=uquota,pquota"` in `/etc/default/grub` file. See https://stackoverflow.com/questions/57248180/docker-per-container-disk-quota-on-bind-mounted-volumes

### The *2-build_all_containers.sh* command does never terminate
Be patient. Try again.

### The product stays inactivated
Enter it in the web ui or go trough console via `$ docker exec -it [container ID] /bin/bash`.

Then `$ /opt/nessus/sbin/nessuscli fetch --register <serial>`

### The plugins are taking time compiling
Let them compile. Take a coffee break.
