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
   ├─ .env
   ├─ database.volume.yml
   ├─ database.yml    
   ├─ adempiere.yml
   ├─ adempiere-last
   ├─ tenant1
   |  ├─ Adempiere_390LTS.tar.gz
   |  ├─ lib
   |  └─ packages
   └─ tenant2
   |  ├─ Adempiere_390LTS.tar.gz
   |  ├─ lib
   |  └─ packages
   ...
   └─ tenantN
   ...
```
#### .env

This file contains the setting variables to Tenant deployment

```
COMPOSE_PROJECT_NAME=eevolution
ADEMPIERE_DB_PORT=55432
ADEMPIERE_DB_PASSWORD=adempiere
ADEMPIERE_DB_ADMIN_PASSWORD=postgres

```
tenant/.env

```
ADEMPIERE_WEB_PORT=8277
ADEMPIERE_SSL_PORT=4444
ADEMPIERE_VERSION=3.9.0
# ATENTION If is "Y" it will be replace de actual defined database with a empty ADempiere seed
ADEMPIERE_DB_INIT=Y 

```

#### tenant dierectory

This directory contains the files needed to deploy and start a particular ADempiere instance of a tenant.
Here we will find:
* The Adempiere tar.gz installer,  if not exist then this will be download from the last stable version.
* lib: The files to copy to the lib directory on ADempiere (this directory will contain the customization and zkcustomization of ADempiere.
* packages: The files to copy to the packages directory on ADempiere (this directory will contain the localization of an ADempiere).


### database.volume.yml

this file will contain the an external database volume 

```
version: '3'
services:
  database:
    volumes:
      - database:/var/lib/postgresql/data/
volumes:
  database:
    driver: local
```

### database.yml

this file will contain the PostgreSQL deployment

```
version: '3'
services:
  database:
    image: postgres:9.6
    restart: always
    ports:
      - "${ADEMPIERE_DB_PORT}:5432"
    networks:
      - custom
    environment:
      - POSTGRES_USER:postgres
      - POSTGRES_PASSWORD:postgres
      - PGDATA:/var/lib/postgresql/data/pgdata
      - POSTGRES_INITDB_ARGS:''
      - POSTGRES_INITDB_XLOGDIR:''
    networks:
      custom:
        external : true     
```      



### adempiere.yml

This file will contain the definition of our ADempiere clients.
For a client we will need to complete the next parametrization.

```
version: '3'
services:
  adempiere-tenant:
    networks:
      - custom
    external_links:
      - database:database
    image: "${COMPOSE_PROJECT_NAME}" # Name of the instance for docker create based on project name
    container_name: "${COMPOSE_PROJECT_NAME}" # Name of the ADempiere client container
    ports:
      - ${ADEMPIERE_WEB_PORT}:8888 # http port where the web client will be exposed
      - ${ADEMPIERE_SSL_PORT}:444 # https port where the web client will be exposed
    environment:
      ADEMPIERE_DB_INIT: ${ADEMPIERE_DB_INIT} # ATENTION If is "Y" it will be replace de actual defined database with a empty ADempiere seed
    build:
      context: .
      dockerfile: ./adempiere-last/Dockerfile
      args:
        ADEMPIERE_BINARY : ${ADEMPIERE_BINARY}
        ADEMPIERE_SRC_DIR: "./${COMPOSE_PROJECT_NAME}" # Directory that contain the ADempiere installer, customization and localization
        ADEMPIERE_DB_HOST: "database"
        ADEMPIERE_DB_PORT: 5432
        ADEMPIERE_DB_NAME: "${COMPOSE_PROJECT_NAME}"
        ADEMPIERE_DB_USER: "${COMPOSE_PROJECT_NAME}"
        ADEMPIERE_DB_PASSWORD: ${ADEMPIERE_DB_PASSWORD}
        ADEMPIERE_DB_ADMIN_PASSWORD: ${ADEMPIERE_DB_ADMIN_PASSWORD}
networks:
  custom:
    external: true
```

### Postgres Container
If you don't have an external database server, You can use the postgres server container defined in this composer. As you will not have a database defined in the container, you can first start the database container to mount it, or you can pass the ADEMPIERE_DB_INIT argument with "Y" to load an ADempiere seed, then you only need to parametrice your ADempiere instances with this database configuration.

### Usage

Edit and define the parameters of your instance

.env 
./eevolution/.env

to do this in terminal we will run the next line:

note : eevolution is name of your tenant

```
./application eevolution up -d 
```


This command will build the images defined in the .env, create the containers and start them. The "-d" parameter will launch the process in background.
To stop the containers you will run the next command.
```
./application eevolution stop
```
Note that in the above command we use the instruction ```stop``` insted of ```down```, this is because the ```down``` instruction delete the containers to, ```stop``` only shutdown them.

If you have a new tenant, you only need to edit and setting the tenant definition to env. and start up only this image and container.

```
./application eevolution up -d 
```

If you need a backup from Database using 

Generate backup : 

```
./application.sh eevolution exec adempiere-tenant /opt/Adempiere/utils/RUN_DBExport.sh
```
Ge backup zip :

```
./application.sh eevolution exec adempiere-tenant "cat /opt/Adempiere/data/ExpDat.dmp" | gzip > "backup.$(date +%F_%R).gz"
```


If you're not familiar with docker-compose and how to manage Docker services through docker-compose have a
look at the [docker compose documentation](https://docs.docker.com/compose)

### Contribution

Contributions are more than welcome. Please log any issue or new feature request in
adempiere-docker project's repository
