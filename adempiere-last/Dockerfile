FROM openjdk:8-jdk
MAINTAINER raul.capecce@openupsolutions.com , victor.perez@e-evolution.com

ARG ADEMPIERE_BINARY
ARG ADEMPIERE_SRC_DIR
ARG ADEMPIERE_DB_HOST
ARG ADEMPIERE_DB_PORT
ARG ADEMPIERE_DB_NAME
ARG ADEMPIERE_DB_USER
ARG ADEMPIERE_DB_PASSWORD
ARG ADEMPIERE_DB_ADMIN_PASSWORD
ARG ADEMPIERE_WEB_PORT

ENV ADEMPIERE_BINARY $ADEMPIERE_BINARY
ENV ADEMPIERE_SRC_DIR $ADEMPIERE_SRC_DIR
ENV ADEMPIERE_DB_HOST $ADEMPIERE_DB_HOST
ENV ADEMPIERE_DB_PORT $ADEMPIERE_DB_PORT
ENV ADEMPIERE_DB_NAME $ADEMPIERE_DB_NAME
ENV ADEMPIERE_DB_USER $ADEMPIERE_DB_USER
ENV ADEMPIERE_DB_PASSWORD $ADEMPIERE_DB_PASSWORD
ENV ADEMPIERE_DB_ADMIN_PASSWORD $ADEMPIERE_DB_ADMIN_PASSWORD
ENV ADEMPIERE_WEB_PORT $ADEMPIERE_WEB_PORT

ENV ADEMPIERE_HOME /opt/Adempiere
ENV AD_DB_Init $AD_DB_Init

COPY $ADEMPIERE_SRC_DIR/$ADEMPIERE_BINARY /tmp
COPY $ADEMPIERE_SRC_DIR/lib /tmp/lib
COPY $ADEMPIERE_SRC_DIR/packages /tmp/packages
COPY ./adempiere-last/start-adempiere.sh /root
COPY ./adempiere-last/define-ad-ctl.sh /root

RUN cd /tmp && \
tar zxvf /tmp/$ADEMPIERE_BINARY && \
mv Adempiere /opt/Adempiere && \
mv lib /opt/Adempiere/lib && \
mv packages /opt/Adempiere/packages && \
chmod -Rf 755 /opt/Adempiere/*.sh && \
chmod -Rf 755 /opt/Adempiere/utils/*.sh && \

sed -i "s/ADEMPIERE_HOME=C.*/ADEMPIERE_HOME=\/opt\/Adempiere/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/JAVA_HOME=C.*/JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/ADEMPIERE_JAVA_OPTIONS=-Xms64M -Xmx512M/ADEMPIERE_JAVA_OPTIONS=-Xms1024M -Xmx4096M/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \

sed -i "s/ADEMPIERE_DB_SERVER=localhost/ADEMPIERE_DB_SERVER=$ADEMPIERE_DB_HOST/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/ADEMPIERE_DB_PORT=5432/ADEMPIERE_DB_PORT=$ADEMPIERE_DB_PORT/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/ADEMPIERE_DB_NAME=adempiere/ADEMPIERE_DB_NAME=$ADEMPIERE_DB_NAME/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/ADEMPIERE_DB_USER=adempiere/ADEMPIERE_DB_USER=$ADEMPIERE_DB_USER/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/ADEMPIERE_DB_PASSWORD=adempiere/ADEMPIERE_DB_PASSWORD=$ADEMPIERE_DB_PASSWORD/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \
sed -i "s/ADEMPIERE_DB_SYSTEM=postgres/ADEMPIERE_DB_SYSTEM=$ADEMPIERE_DB_ADMIN_PASSWORD/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \

sed -i "s/ADEMPIERE_KEYSTORE=C*/ADEMPIERE_KEYSTORE=\/data\/app\/Adempiere\/keystore\/myKeystore/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \

sed -i "s/ADEMPIERE_WEB_ALIAS=localhost/ADEMPIERE_DB_SYSTEM=$(hostname)/g" /opt/Adempiere/AdempiereEnvTemplate.properties && \

JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" && \

chmod +x /root/define-ad-ctl.sh && sync && \
/root/define-ad-ctl.sh && sync && \

cd /opt/Adempiere && \
cp AdempiereEnvTemplate.properties AdempiereEnv.properties && \
cp utils/myEnvironmentTemplate.sh utils/myEnvironment.sh && \

chmod 755 /root/start-adempiere.sh && \


apt update && \
apt install -y postgresql postgresql-contrib


CMD /root/start-adempiere.sh > /tmp/start-adempiere.log
