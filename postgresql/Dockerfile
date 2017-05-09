#
# This file is part of Adempiere ERP Bazaar - http://www.adempiere.org
#
# Copyright (C) Sergio Ramazzina - Serasoft S.r.l.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
# 
# Contributors:
# - Sergio Ramazzina - sergio.ramazzina@serasoft.it
#

#
# Dockerfile  to build an ADempiere image that connects to an external 
# PostgreSQL database instance
#

FROM serasoft/openjdk-base:8u121
MAINTAINER sergio.ramazzina@serasoft.it

# Required build arguments (es --build-arg ADEMPIERE_REL=390LTS)
ARG ADEMPIERE_REL

# Environment Variables
ENV ADEMPIERE_HOME /data/app/Adempiere

RUN apt-get update && \
    apt-get install -f -y git postgresql-client && \ 
    mkdir -p /data/app && \
    chmod -R 777 /data/app

COPY ./dist/Adempiere_${ADEMPIERE_REL}.tar.gz /data/app
COPY pg_setup.sql /data/app
COPY wait-for-postgres.sh /data/app

RUN cd /data/app && \
    tar -xvzf Adempiere_${ADEMPIERE_REL}.tar.gz && \
    rm Adempiere_${ADEMPIERE_REL}.tar.gz && \
    chmod -Rf 755 ./*.sh && \
    cd ./Adempiere && \
    chmod -Rf 755 ./*.sh && \
    chmod -Rf 755 ./utils/*.sh && \
    sed "s/ADEMPIERE_HOME=C*....Adempiere/ADEMPIERE_HOME=\/data\/app\/Adempiere/g" /data/app/Adempiere/AdempiereEnvTemplate.properties > /data/app/Adempiere/AdempiereEnv.tmp.1 && \
    sed "s/JAVA_HOME=C*..................................../JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/g" /data/app/Adempiere/AdempiereEnv.tmp.1 > /data/app/Adempiere/AdempiereEnv.tmp.2 && \
    sed "s/ADEMPIERE_DB_SERVER=localhost/ADEMPIERE_DB_SERVER=postgres-db/g" /data/app/Adempiere/AdempiereEnv.tmp.2 > /data/app/Adempiere/AdempiereEnv.tmp.3 && \
    sed "s/ADEMPIERE_APPS_SERVER=localhost/ADEMPIERE_APPS_SERVER=adempiere-postgres/g" /data/app/Adempiere/AdempiereEnv.tmp.3 > /data/app/Adempiere/AdempiereEnv.tmp.4 && \
    sed "s/ADEMPIERE_WEB_PORT=8888/ADEMPIERE_WEB_PORT=9080/g" /data/app/Adempiere/AdempiereEnv.tmp.4 > /data/app/Adempiere/AdempiereEnv.tmp.5 && \
    sed "s/ADEMPIERE_SSL_PORT=4444/ADEMPIERE_SSL_PORT=4443/g" /data/app/Adempiere/AdempiereEnv.tmp.5 > /data/app/Adempiere/AdempiereEnv.tmp.6 && \
    sed "s/ADEMPIERE_JAVA_OPTIONS=-Xms64M -Xmx512M/ADEMPIERE_JAVA_OPTIONS=-Xms1024M -Xmx4096M/g" /data/app/Adempiere/AdempiereEnv.tmp.6 > /data/app/Adempiere/AdempiereEnv.tmp.7 && \
    sed "s/ADEMPIERE_KEYSTORE=C*..................................../ADEMPIERE_KEYSTORE=\/data\/app\/Adempiere\/keystore\/myKeystore/g" /data/app/Adempiere/AdempiereEnv.tmp.7 > /data/app/Adempiere/AdempiereEnv.properties && \
    cat /data/app/Adempiere/AdempiereEnv.properties && \
    echo "postgres-db:5432:postgres:postgres:postgres" > /root/.pgpass && \
    echo "postgres-db:5432:adempiere:adempiere:adempiere" >> /root/.pgpass && \
    sed "s/ start / run /g" /data/app/Adempiere/tomcat/bin/startup.sh  > /data/app/Adempiere/tomcat/bin/startup.tmp && \
    mv /data/app/Adempiere/tomcat/bin/startup.sh /data/app/Adempiere/tomcat/bin/startup.sh.ori && \
    mv /data/app/Adempiere/tomcat/bin/startup.tmp /data/app/Adempiere/tomcat/bin/startup.sh && \
    chmod -Rf 600 /root/.pgpass

ADD root /

EXPOSE 9080 4443
