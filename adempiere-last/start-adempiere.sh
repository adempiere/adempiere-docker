#!/bin/bash

################################################################################
#  ADempiere start script                                                     ##
#  Starting check if is needed init the database (ENV: AD_DB_Init = true)     ##
#                                                                             ##
#  OpenUp Solutions                                                           ##
#  Raul Capecce                                                               ##
#  raul.capecce@openupsolutions.com                                           ##
################################################################################

ENV_FILE=/root/AdempiereEnvDocker.properties

export PGPASSWORD=$ADEMPIERE_DB_ADMIN_PASSWORD

if [ -f $ENV_FILE ]; then
  source $ENV_FILE
fi

echo "HOST: $ADEMPIERE_DB_HOST"
until psql -h $ADEMPIERE_DB_HOST -p $ADEMPIERE_DB_PORT -U "postgres" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

# Run Setup if it hasn't been runned
if [ "$AD_SETED_CONFIGURATION" != "Y" ]; then
  cd /opt/Adempiere
  ./RUN_silentsetup.sh
  AD_SETED_CONFIGURATION=Y
fi

# Run initialization of the data base
if [ "$ADEMPIERE_DB_INIT" = "Y" ]; then
  if [ "$ALREADY_ADEMPIERE_DB_INIT" = "Y" ]; then
    echo "================================================================================"
    echo "==                           * * *   WARNING  * * *                           =="
    echo "== Database already initialized                                               =="
    echo "== Please disable ADEMPIERE_DB_INIT argument in docker-compose.yml file       =="
    echo "== If you want to initialize the database again, first start the container    =="
    echo "== with this argument in N and then start it with this argument in Y          =="
    echo "================================================================================"
  else
    echo "================================================================================"
    echo "==               * * *   ADempiere Docker: RESTORING DB  * * *                =="
    echo "================================================================================"
    cd /opt/Adempiere/utils
    psql -h $ADEMPIERE_DB_HOST -p $ADEMPIERE_DB_PORT -U postgres -c "DROP ROLE IF EXISTS adempiere"
    psql -h $ADEMPIERE_DB_HOST -p $ADEMPIERE_DB_PORT -U postgres -c "CREATE ROLE adempiere LOGIN PASSWORD '$ADEMPIERE_DB_PASSWORD'"
    ./RUN_ImportAdempiere.sh silent
    ALREADY_ADEMPIERE_DB_INIT=Y
  fi
else
  echo "================================================================================"
  echo "==  ADempiere Docker: DB not restored                                         =="
  echo "================================================================================"
  ALREADY_ADEMPIERE_DB_INIT=N
fi

# Setting environment docker file
echo "# ADempiere Docker Environment File" > $ENV_FILE
echo "AD_SETED_CONFIGURATION=$AD_SETED_CONFIGURATION" >> $ENV_FILE
echo "ALREADY_ADEMPIERE_DB_INIT=$ALREADY_ADEMPIERE_DB_INIT" >> $ENV_FILE


cd /opt/Adempiere/utils
chmod 755 *.sh 
./RUN_Server2.sh
tail -f /dev/null

exit 0
