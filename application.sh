#  Copyright (C) 2003-2017, e-Evolution Consultants S.A. , http://www.e-evolution.com
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#  Email: victor.perez@e-evolution.com, http://www.e-evolution.com , http://github.com/e-Evolution

#!/usr/bin/env bash
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -z "$1" ];
then
    echo "ADempiere instance name, should use application.sh <instance name> up -d "
    exit 1
fi


# load environment variables
. .env

export COMPOSE_PROJECT_NAME=$1;
echo "Instance $COMPOSE_PROJECT_NAME"
. ./$COMPOSE_PROJECT_NAME/.env

if [ -z "$ADEMPIERE_WEB_PORT" ];
then
    echo "ADempiere HTTP port not setting"
    exit 1
fi

if [ -z "$ADEMPIERE_SSL_PORT" ];
then
    echo "ADempiere HTTPS port not setting"
    exit 1
fi

if [ -z "$ADEMPIERE_DB_INIT" ];
then
    echo "Initialize Database not setting"
    exit 1
fi

if [ -z "$ADEMPIERE_VERSION" ];
then
    echo "ADempiere version not setting"
    exit 1
fi

export ADEMPIERE_WEB_PORT;
export ADEMPIERE_SSL_PORT;
export ADEMPIERE_DB_INIT;

echo "ADempiere HTTP  port: $ADEMPIERE_WEB_PORT"
echo "ADempiere HTTPS port: $ADEMPIERE_SSL_PORT"
echo "Initialize Database $ADEMPIERE_DB_INIT"


if [ "$(docker network inspect -f '{{.Name}}' custom)" != "custom" ];
then
    echo "Create custom network"
    docker network create -d bridge custom
fi

RUNNING=$(docker inspect --format="{{.State.Running}}" postgres96_database_1 2> /dev/null)
if [ $? -eq 1 ]; then
  echo "Dababase container does not exist."
  echo "Create Database container"
    docker-compose \
        -f "$BASE_DIR/database.yml" \
        -f "$BASE_DIR/database.volume.yml" \
        -p postgres96 \
        up -d
fi

if [ "$RUNNING" == "false" ];
then
echo "CRITICAL - postgres96_database_1 is not running."
echo "Starting Database"
docker-compose \
    -f "$BASE_DIR/database.yml" \
    -f "$BASE_DIR/database.volume.yml" \
    -p postgres96 \
    start
fi

if [ "$RUNNING" == "true" ];
then
   docker-compose \
        -f "$BASE_DIR/database.yml" \
        -f "$BASE_DIR/database.volume.yml" \
        -p postgres96 \
        config
fi

# Define Adempiere path and binary
ADEMPIERE_PATH="./$COMPOSE_PROJECT_NAME"
ADEMPIERE_BINARY=Adempiere_${ADEMPIERE_VERSION//.}"LTS.tar.gz"
export ADEMPIERE_BINARY;
URL="https://github.com/adempiere/adempiere/releases/download/"$ADEMPIERE_VERSION"/"$ADEMPIERE_BINARY

if [ -d "$ADEMPIERE_PATH" ]
then
    if [ -f "$ADEMPIERE_PATH/$ADEMPIERE_BINARY" ]
    then
       echo "Installed based on ADempiere $ADEMPIERE_VERSION"
    else
       echo "Adempiere Path $ADEMPIERE_PATH"
       echo "Adempiere Version $ADEMPIERE_VERSION"
       echo "Adempiere Binary $ADEMPIERE_PATH/$ADEMPIERE_BINARY"
       echo "Download from $URL"
       curl -L $URL > "$ADEMPIERE_PATH/$ADEMPIERE_BINARY"
       if [ -f "$ADEMPIERE_PATH/$ADEMPIERE_BINARY" ]
       then
         echo "Adempiere Binary download successful"
       else
              "Adempiere Binary not download"
              exit
       fi
    fi

    # Execute docker-compose
    echo
    docker-compose \
            -f "$BASE_DIR/adempiere.yml" \
            -p "$COMPOSE_PROJECT_NAME" \
            $2 \
            $3 \
            $4 \
            $5
else
    echo "Project directory not found for : $COMPOSE_PROJECT_NAME "
fi