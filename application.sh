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
# load environment variables
. .env

if [ $(docker network inspect -f '{{.Name}}' custom) != "custom" ];
then
    echo "Create custom network"
    docker network create -d bridge custom
fi

if [ $(docker inspect -f '{{.State.Running}}' postgres96_database_1) = "true" ];
then
    echo "Database container is running"
else
    echo "Create Database container"
    docker-compose \
        -f "$BASE_DIR/database.yml" \
        -f "$BASE_DIR/database.volume.yml" \
       "$@" \
       -p postgres96_database_1
fi

# Define Adempiere path and binary
ADEMPIERE_PATH="./$COMPOSE_PROJECT_NAME"
ADEMPIERE_BINARY=Adempiere_${ADEMPIERE_VERSION//.}"LTS.tar.gz"
export ADEMPIERE_BINARY;
URL="https://github.com/adempiere/adempiere/releases/download/"$ADEMPIERE_VERSION"/"$ADEMPIERE_BINARY

echo "Adempiere Path $ADEMPIERE_PATH"
echo "Adempiere Version $ADEMPIERE_VERSION"
echo "Adempiere Binary $ADEMPIERE_PATH/$ADEMPIERE_BINARY"
echo "Download from $URL"


if [ -d "$ADEMPIERE_PATH" ]
then
    if [ -f "$ADEMPIERE_PATH/$ADEMPIERE_BINARY" ]
    then
        echo "Installed based on $ADEMPIERE_PATH/$ADEMPIERE_BINARY"
    else
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
    docker-compose \
            -f "$BASE_DIR/adempiere.yml" \
            "$@"
else
    echo "Project directory not found for : $COMPOSE_PROJECT_NAME "
fi