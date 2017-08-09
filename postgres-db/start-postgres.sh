#!/bin/bash

################################################################################
#  Postgres start script                                                      ##
#  Starting check and create PostgreSQL data directory if not exists          ##
#                                                                             ##
#  OpenUp Solutions                                                           ##
#  Raul Capecce                                                               ##
#  raul.capecce@openupsolutions.com                                           ##
################################################################################



# Check if the postgres data directory not exists
if find "/var/lib/postgresql/$PG_VERSION/main/" -mindepth 1 -print -quit | grep -q .; then

echo "================================================================================"
echo "==  ADempiere postgres volume already defined!                                =="
echo "================================================================================"

/etc/init.d/postgresql start && sync

else

echo "================================================================================"
echo "==  INIT ADempiere postgres volume!                                           =="
echo "================================================================================"


# Creating postgres data, if exists nothing happens
mkdir -p /var/lib/postgresql/$PG_VERSION/main/

# Setting permissions to data folder
chown postgres:postgres /var/lib/postgresql/$PG_VERSION/main/

# Init DB postgres data directory
su - postgres -c "/usr/lib/postgresql/$PG_VERSION/bin/initdb /var/lib/postgresql/$PG_VERSION/main/"

/etc/init.d/postgresql start && sync

# Setting adempiere rolename
su - postgres -c "psql postgres" << EOF
CREATE ROLE adempiere LOGIN PASSWORD '$PG_AdempierePsw' SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
EOF

# Setting postgres rolename
su - postgres -c "psql postgres" << EOF
ALTER ROLE postgres PASSWORD '$PG_PGAdminPsw';
EOF

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$PG_VERSION/main/postgresql.conf
sed -i "s/max_connections = 100/max_connections = $PG_MaxConnections/g" /etc/postgresql/$PG_VERSION/main/postgresql.conf
sed -i "s/ident/md5/g" /etc/postgresql/$PG_VERSION/main/pg_hba.conf
echo "host    all             all             $PG_Net/$PG_NetMask          md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf
echo "host    all             all             10.8.0.0/24             md5" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf



/etc/init.d/postgresql stop && sync
/etc/init.d/postgresql start && sync

echo "================================================================================"
echo "==  Created ADempiere postgres volume!                                        =="
echo "================================================================================"

fi


tail -f /var/log/postgresql/postgresql-$PG_VERSION-main.log


exit 0


