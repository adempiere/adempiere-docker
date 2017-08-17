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

if [ -f $ENV_FILE ]; then
  source $ENV_FILE
fi

echo "HOST: $ADEMPIERE_DB_HOST"
until psql -h $ADEMPIERE_DB_HOST -p $ADEMPIERE_DB_PORT -U "postgres" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

if [ "$AD_SETED_CONFIGURATION" != "Y" ]; then

  cd /opt/Adempiere
  ./RUN_silentsetup.sh

  if [ "$ADEMPIERE_DB_INIT" = "Y" ]; then
    echo "============ INIT DB ============"
    cd /opt/Adempiere/utils
    Y|./RUN_ImportAdempiere.sh
  else
    echo "========== NO INIT DB ==========="
  fi

  echo "AD_SETED_CONFIGURATION=Y" > $ENV_FILE
fi

cd /opt/Adempiere/utils
./RUN_Server2.sh
tail -f /dev/null

exit 0
