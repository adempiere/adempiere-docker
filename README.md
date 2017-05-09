# ADempiere Docker Official Repository

[![Join the chat at https://gitter.im/adempiere/adempiere-docker](https://badges.gitter.im/adempiere/adempiere-docker.svg)](https://gitter.im/adempiere/adempiere-docker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Welcome to the official repository for ADempiere Docker. This project is related 
with the maintenance of an official image for ADempiere.

### Status 

* This project is at a beta stage.
* All the documentation is preliminary and subject to be changed and further improved..

### What's released so far

* Dockerfile for an ADempiere image that connects to an external Postgresql container instance
* compose file to start both the ADempiere instance and a PostgreSQL instance for ease of use

### Project's structure

The adempiere-docker project follows the structure specified below

```
└─ adempiere-docker
   ├─ compose
   |  └─ postgresql
   ├─ postgresql
   |  └─ dist
   └─ old
```

#### compose/postgresql

This directory contains the compose file that starts both the ADempiere container 
and the PostgreSQL container.

#### postgresql

This directory contains everything related with the build of the Docker 
container for PostgreSQL.

#### postgresql/dist

This directory contains the _.tar.gz_ archive of the ADempiere binary release
we want to deliver through the container. The name of the archive must be
formatted like this

Adempiere&#95;&#60;rel-name&#62;.tar.gz

where _rel-name_ is the identifier of the ADempiere release (es.: 390LTS)

#### old 

This directories contains the old container files that wil be soon removed from 
the project but, for the moment, are kept there for reference.

### How to build the image

After the repository has been cloned follow the steps detailed below.

* Copy the archive of the ADempiere distribution you want to deploy in the 
container in the _postgresql/dist_ directory (es.: ADempiere_390LTS.tar.gz for current 
390 release)
* Open a terminal window.
* Go to the _adempiere-docker/postgresql_ directory. 
* From the command prompt, type the following command:

```
docker build --rm -t adempiere:390LTS --build-arg ADEMPIERE_REL=390LTS .
```

### Run the ADempiere docker instance

As soon as the image has been built successfully, you can run the image by following the
steps detailed below

* Open a terminal window.
* Go to the adempiere-docker/compose/postgresql directory. 
* From the command prompt, type the following command:

```
docker-compose up -d
```

This command starts the services in daemon mode. The current docker-compose.yml is a sample of how to make things work and contains a very basic configuration.

Notice that the first time you run the image, it will take a considerable aomunt of time to start the ADempiere container because of the time to initialize the system starting from default ADempiere seed. This initialization phase is made just the very first time the container runs. I suggest you to keep an eye on how the things are progressing by checking the container's logs. To check container logs, type the following command on a termina window:

```
docker-compose logs -f adempiere
```

If you're not familiar with docker-compose and how to manage Docker services through docker-compose have a 
look at the [docker compose documentation](https://docs.docker.com/compose)

### Contribution

Contributions are more than welcome. Please log any issue or new feature request in 
adempiere-docker project's repository.




