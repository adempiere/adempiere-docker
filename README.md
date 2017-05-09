# ADempiere Docker Official Repository

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
   ├─ dist
   ├─ compose
   |  └─ postgresql
   ├─ postgresql
   └─ old
```

#### dist
This directory contains the _.tar.gz_ archive of the ADempiere binary release 
we want to deliver through the container. The name of the archive must be 
formatted like this

Adempiere_<rel-name>.tar.gz

where _rel-name_ is the identifier of the ADempiere release (es.: 390LTS)

#### compose/postgresql

This directory contains the compose file that starts both the ADempiere container 
and the PostgreSQL container.

#### postgresql

This directory contains everything related with the build of the Docker 
container for PostgreSQL.

#### old 

This directories contains the old container files that wil be soon removed from 
the project but, for the moment, are kept there for reference.

### How to build the image

After the repository has been cloned follow the steps detailed below.

* Copy the archive of the ADempiere distribution you want to deploy in the 
container in the _dist_ directory (es.: ADempiere_390LTS.tar.gz for current 
390 release)
* Open a terminal window.
* Go to the adempiere-docker/postgresql directory. 
* From the command prompt, type the following command:

```
adempiere-docker git:(master) docker build --rm -t adempiere:390LTS --build-arg ADEMPIERE_REL=390LTS .
```

### Run the ADempiere docker instance

As soon as the image has been built successfully, you can run the image by following the
steps detailed below

* Open a terminal window.
* Go to the adempiere-docker/compose/postgresql directory. 
* From the command prompt, type the following command:

```
adempiere-docker git:(master) docker-compose up -d
```

This command starts the containers in daemon mode.

The first time you run the image it will take a considerable aomunt of time because
ADempiere's tables will be initialized starting from default ADempiere seed. I suggest
you to keep an eye on how the things are progressing by typing the following command:

```
adempiere-docker git:(master) docker-compose logs -f adempiere
```

If you're not familiar with docker-compose and how to manage Docker services through docker-compose have a 
look at the [docker compose documentation](https://docs.docker.com/compose)

### Contribution

Contributions are more than welcome. Please log any issue or new feature request in 
adempiere-docker project's repository.




