# ADempiere Docker Official Repository

[![Join the chat at https://gitter.im/adempiere/adempiere-docker](https://badges.gitter.im/adempiere/adempiere-docker.svg)](https://gitter.im/adempiere/adempiere-docker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Welcome to the official repository for ADempiere Docker. This project is related
with the maintenance of an official image for ADempiere.

## Minimal Docker Requirements

To use this Docker image you must have your Docker engine release number greater
than or equal to 3.0.
To check the version of your Docker installation, a terminal window and type the
following command:

```
docker info
```

The expected output is as follow

```
Containers: 4
 Running: 2
 Paused: 0
 Stopped: 2
Images: 69
Server Version: 17.04.0-ce
Storage Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 114
 Dirperm1 Supported: false
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary:
containerd version: 422e31ce907fd9c3833a38d7b8fdd023e5a76e73
runc version: 9c2d8d184e5da67c95d601382adf14862e4f2228
init version: 949e6fa
Security Options:
 apparmor
Kernel Version: 3.13.0-24-generic
Operating System: Ubuntu 14.04.5 LTS
OSType: linux
Architecture: x86_64
CPUs: 2
Total Memory: 7.675GiB
Name: cub8
ID: SZGL:IHMR:NBGN:MCIE:SWOK:TO5N:FBML:W5IW:BPRR:C2DP:WZLQ:S75V
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Username: sramazzina
Registry: https://index.docker.io/v1/
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
```

To verify the Docker version you're running on your server look at the _Server Version_ property.

### Status

* This project is at a beta stage for development environments.
* All the documentation is preliminary and subject to be changed and further improved..

### Project's structure

The adempiere-docker project follows the structure specified below

```
└─ adempiere-docker
   ├─ docker-compose.yml
   ├─ adempiere-last
   ├─ client1
   |  ├─ Adempiere_390LTS.tar.gz
   |  ├─ lib
   |  └─ packages
   └─ client2
   |  ├─ Adempiere_390LTS.tar.gz
   |  ├─ lib
   |  └─ packages
   ...
   └─ clientN
   ...
```

#### client1

This directory contains the files needed to deploy and start a particular ADempiere instance of a client.
Here we will find:
* The Adempiere tar.gz installer.
* lib: The files to copy to the lib directory on ADempiere (this directory will contain the customization and zkcustomization of ADempiere.
* packages: The files to copy to the packages directory on ADempiere (this directory will contain the localization of an ADempiere).

### docker-compose.yml

This file will contain the definition of our ADempiere clients.
For a client we will need to complete the next parametrization.

```
  adempiere-client1:  # Name of the ADempiere client for docker
    depends_on:
      - db
    image: adempiere-client1  # Name of the ADempiere client image
    container_name: adempierec-client1  # Name of the ADempiere client container
    ports:
      - <<port>>:8888  # Port where the web client will be exposed
    environment:
      ADEMPIERE_DB_INIT: N  # ATENTION If is "Y" it will be replace de actual defined database with a empty ADempiere Seed
    build:
      context: .
      dockerfile: ./adempiere-last/Dockerfile
      args:
        ADEMPIERE_REL: 390LTS
        ADEMPIERE_SRC_DIR: ./client1  # Directory that contain the ADempiere installer, customization and localization
        ADEMPIERE_DB_HOST: <<ip adress>>  # Address of the database host
        ADEMPIERE_DB_PORT: <<port>>  # Port of the database host
        ADEMPIERE_DB_NAME: <<database name>>
        ADEMPIERE_DB_USER: <<database user>>
        ADEMPIERE_DB_PASSWORD: <<password database user>>
        ADEMPIERE_DB_ADMIN_PASSWORD: <<admin password>>
```

### Postgres Container
If you don't have an external database server, You can use the postgres server container defined in this composer. As you will not have a database defined in the container, you can first start the database container to mount it, or you can pass the ADEMPIERE_DB_INIT argument with "Y" to load an ADempiere seed, then you only need to parametrice your ADempiere instances with this database configuration.

### Usage
If you already have configured the docker-compose.yml, you only need to start the dockers container, to do this in terminal we will run the next line:
```
cd <<directory_of_docker-compose.yml>>
docker-compose up -d
```
This command will build the images defined in the docker-compose.yml, create the containers and start them. The "-d" parameter will launch the process in background.
To stop the containers you will run the next command.
```
docker-compose stop
```
Note that in the above command we use the instruction ```stop``` insted of ```down```, this is because the ```down``` instruction delete the containers to, ```stop``` only shutdown them.

If you have a new client, you only need to add this client definition to the docker-compose.yml and start up only this image and container.
```
docker-compose up -d client3
```


If you're not familiar with docker-compose and how to manage Docker services through docker-compose have a
look at the [docker compose documentation](https://docs.docker.com/compose)

### Contribution

Contributions are more than welcome. Please log any issue or new feature request in
adempiere-docker project's repositor
